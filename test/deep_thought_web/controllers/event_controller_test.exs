defmodule DeepThoughtWeb.EventControllerTest do
  use DeepThoughtWeb.ConnCase

  alias DeepThought.Slack
  alias DeepThought.Slack.Event

  @create_attrs %{
    type: "some type"
  }
  @invalid_attrs %{type: nil}

  def fixture(:event) do
    {:ok, event} = Slack.create_event(@create_attrs)
    event
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create event" do
    test "renders event when data is valid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.event_path(conn, :show, id))

      assert %{
               "id" => id,
               "type" => "some type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.event_path(conn, :create), event: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_event(_) do
    event = fixture(:event)
    %{event: event}
  end
end
