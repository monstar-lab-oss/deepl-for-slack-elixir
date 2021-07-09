defmodule DeepThought.DeepL.APITest do
  @moduledoc """
  Module used to test the interaction with the DeepL translation API.
  """

  use DeepThought.MockCase, async: true

  test "translate/2 can return translated text" do
    assert {:ok, "Ahoj, světe!"} == DeepL.API.translate("Hello, world!", "CS")
  end
end
