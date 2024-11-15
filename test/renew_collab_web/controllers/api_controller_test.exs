defmodule RenewCollabWeb.ApiControllerTest do
  use RenewCollabWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "api root", %{conn: conn} do
      conn = get(conn, ~p"/api")
      assert json_response(conn, 200)
    end
  end
end
