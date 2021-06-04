defmodule DeepThought.DeepL.API do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.deepl.com/v2")
  plug(Tesla.Middleware.EncodeFormUrlencoded)
  plug(Tesla.Middleware.DecodeJson)

  @auth_key Application.get_env(:deep_thought, :deepl)[:auth_key]
  @headers [{"content-type", "application/x-www-form-urlencoded"}]

  def translate(text, target_language) do
    with {:ok, response} <-
           post("/translate", translate_request_body(text, target_language), headers: @headers),
         body when is_map(body) <- response.body(),
         [translation | _] <- Map.get(body, "translations"),
         text <- Map.get(translation, "text") do
      {:ok, text}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        {:ok, ":x: Failed to translate due to an unexpected response from DeepL API"}
    end
  end

  defp translate_request_body(text, target_language),
    do: %{
      "auth_key" => @auth_key,
      "text" => text,
      "target_lang" => target_language,
      "tag_handling" => "xml",
      "ignore_tags" => "emoji,link,username"
    }
end
