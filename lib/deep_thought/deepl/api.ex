defmodule DeepThought.DeepL.API do
  @moduledoc """
  Module used to interact with the DeepL translation API. In order to use functions defined in this module,
  an environmental variable `DEEPL_AUTH_KEY` (which gets loaded into application config) is required, containing the
  value of the DeepL auth key generated in your DeepL Pro account. Currently, the paid version of the DeepL API is
  always called, which doesn’t work with free auth key.
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.deepl.com/v2"
  plug Tesla.Middleware.Query, auth_key: Application.get_env(:deep_thought, :deepl)[:auth_key]
  plug Tesla.Middleware.EncodeFormUrlencoded
  plug Tesla.Middleware.DecodeJson
  plug Tesla.Middleware.Logger

  @doc """
  Invoke DeepL’s translation API, converting `text` into a translation in `target_language`.
  """
  @spec translate(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def translate(text, target_language) do
    result = post("/translate", translate_request_body(text, target_language))

    case result do
      {:ok, response} ->
        case response.status() do
          200 ->
            {:ok, Enum.at(response.body()["translations"], 0)["text"]}

          _ ->
            {:error, "Failed to translate due to an unexpected response from translation server"}
        end

      _ ->
        {:error, "Failed to translate due to an unexpected response from translation server"}
    end
  end

  @spec translate_request_body(String.t(), String.t()) :: %{String.t() => String.t()}
  defp translate_request_body(text, target_language),
    do: %{
      "text" => text,
      "target_lang" => target_language,
      "tag_handling" => "xml",
      "ignore_tags" => "emoji,link,username"
    }
end
