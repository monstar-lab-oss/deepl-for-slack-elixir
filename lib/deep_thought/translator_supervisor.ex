defmodule DeepThought.TranslatorSupervisor do
  def translate(event_details, reaction, channel_id, message_ts) do
    Task.Supervisor.start_child(
      __MODULE__,
      DeepThought.DeepL.Translator,
      :translate,
      [event_details, reaction, channel_id, message_ts],
      restart: :transient
    )
  end

  def delete(payload) do
    Task.Supervisor.start_child(__MODULE__, DeepThought.DeepL.Translator, :delete, [payload],
      restart: :transient
    )
  end

  def simple_translate(channel_id, text, username, user_id) do
    Task.Supervisor.start_child(
      __MODULE__,
      DeepThought.DeepL.SimpleTranslator,
      :simple_translate,
      [channel_id, text, username, user_id],
      restart: :transient
    )
  end
end
