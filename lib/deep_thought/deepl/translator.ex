defmodule DeepThought.DeepL.Translator do
  alias DeepThought.DeepL
  alias DeepThought.Slack
  alias DeepThought.Slack.LanguageConverter

  def translate(event_details, reaction, channel_id, message_ts) do
    case LanguageConverter.reaction_to_lang(reaction) do
      {:ok, language} ->
        unless Slack.recently_translated?(channel_id, message_ts, language) do
          {:ok, [message | _]} = Slack.API.conversations_replies(channel_id, message_ts)
          message_text = escape_message_text(message)
          {:ok, translation} = DeepL.API.translate(message_text, language)
          translatedText = handle_usernames(translation)

          :ok =
            say_in_thread(channel_id, translatedText, message, message_text |> handle_usernames)

          params = create_translation_event_params(event_details, language)

          Slack.create_event(params)
        end

      :error ->
        nil
    end
  end

  def delete(payload) do
    %{
      "actions" => [%{"selected_option" => %{"value" => "delete"}}],
      "container" => %{
        "channel_id" => channel_id,
        "message_ts" => message_ts,
        "thread_ts" => thread_ts
      },
      "user" => %{"id" => user_id}
    } = Jason.decode!(payload)

    :ok = Slack.API.chat_delete(channel_id, message_ts)
    message = "I deleted the translation."

    Slack.API.chat_post_ephemeral(channel_id, user_id, message, thread_ts)
  end

  defp handle_usernames(message_text) do
    message_text
    |> unescape_message_text()
    |> collect_user_ids()
    |> load_cached_user_ids()
    |> replace_all_user_ids()
  end

  defp load_cached_user_ids({message_text, user_ids}) do
    resolved_usernames = Slack.find_users(user_ids)

    resolved_user_ids =
      resolved_usernames
      |> Enum.map(& &1.user_id)

    {message_text, resolved_usernames, user_ids -- resolved_user_ids}
  end

  defp replace_all_user_ids({message_text, resolved, unresolved_user_ids}) do
    stream =
      Task.async_stream(unresolved_user_ids, fn user_id ->
        {:ok, %{"real_name" => real_name}} = Slack.API.users_profile_get(user_id)
        {user_id, real_name}
      end)

    usernames =
      Enum.reduce(stream, [], fn {:ok, {user_id, real_name}}, acc ->
        [%{user_id: user_id, real_name: real_name} | acc]
      end)

    Slack.upsert_users(usernames)

    Enum.reduce(
      usernames ++ resolved,
      message_text,
      fn %{real_name: real_name, user_id: user_id}, acc ->
        String.replace(acc, "<@#{user_id}>", " `@#{real_name}`")
      end
    )
  end

  defp collect_user_ids(message_text) do
    {message_text,
     Regex.scan(~r/<@(\S+)>/i, message_text, capture: :all_but_first)
     |> List.flatten()
     |> Enum.uniq()}
  end

  defp escape_message_text(%{"text" => message_text}) do
    message_text
    |> escape_usernames()
    |> escape_emojis()
    |> escape_links()
  end

  defp escape_usernames(text) do
    Regex.replace(~r/<([!@#]\S+)>/i, text, fn _, username ->
      "<username>&lt;" <> username <> "&gt;</username>"
    end)
  end

  defp escape_emojis(text) do
    Regex.replace(~r/(:\S+:)/i, text, fn _, emoji ->
      "<emoji>" <> emoji <> "</emoji>"
    end)
  end

  defp escape_links(text) do
    Regex.replace(~r/<(http\S+)>/i, text, fn _, link ->
      "<link>" <> link <> "</link>"
    end)
  end

  defp unescape_message_text(message_text) do
    message_text
    |> unescape_usernames()
    |> unescape_emojis()
    |> unescape_links()
  end

  defp unescape_usernames(text) do
    Regex.replace(~r/<username>&lt;([!@#]\S+)&gt;<\/username>/i, text, fn
      _, "!" <> global ->
        "`!" <> global <> "`"

      _, "@" <> username ->
        "<@" <> username <> ">"

      _, "#" <> channel_name ->
        "<#" <> channel_name <> ">"
    end)
  end

  defp unescape_emojis(text) do
    Regex.replace(~r/<\/?emoji>/i, text, "")
  end

  defp unescape_links(text) do
    Regex.replace(~r/<\/?link>/i, text, "")
  end

  defp create_translation_event_params(
         %{"item" => %{"channel" => channel_id, "ts" => message_ts}, "type" => type},
         language
       ) do
    %{
      "type" => type,
      "target_language" => language,
      "channel_id" => channel_id,
      "message_ts" => message_ts
    }
  end

  defp say_in_thread(channel_id, text, message, original_text) do
    blocks =
      [
        Slack.TranslationBlock.generate(text),
        Slack.FooterBlock.generate(message, channel_id, original_text)
      ]
      |> Jason.encode!()

    Slack.API.chat_post_message(channel_id, text,
      blocks: blocks,
      thread_ts: get_thread_ts(message)
    )
  end

  defp get_thread_ts(%{"thread_ts" => thread_ts}), do: thread_ts
  defp get_thread_ts(%{"ts" => ts}), do: ts
end
