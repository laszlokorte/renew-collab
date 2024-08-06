defmodule RenewCollabWeb.ElementControllerTest do
  use RenewCollabWeb.ConnCase

  import RenewCollab.RenewFixtures

  alias RenewCollab.Renew.Element

  @create_attrs %{
    z_index: 42,
    position_x: 120.5,
    position_y: 120.5
  }
  @update_attrs %{
    z_index: 43,
    position_x: 456.7,
    position_y: 456.7
  }
  @invalid_attrs %{z_index: nil, position_x: nil, position_y: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all element", %{conn: conn} do
      conn = get(conn, ~p"/api/element")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create element" do
    test "renders element when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/element", element: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/element/#{id}")

      assert %{
               "id" => ^id,
               "position_x" => 120.5,
               "position_y" => 120.5,
               "z_index" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/element", element: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update element" do
    setup [:create_element]

    test "renders element when data is valid", %{conn: conn, element: %Element{id: id} = element} do
      conn = put(conn, ~p"/api/element/#{element}", element: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/element/#{id}")

      assert %{
               "id" => ^id,
               "position_x" => 456.7,
               "position_y" => 456.7,
               "z_index" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, element: element} do
      conn = put(conn, ~p"/api/element/#{element}", element: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete element" do
    setup [:create_element]

    test "deletes chosen element", %{conn: conn, element: element} do
      conn = delete(conn, ~p"/api/element/#{element}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/element/#{element}")
      end
    end
  end

  defp create_element(_) do
    element = element_fixture()
    %{element: element}
  end
end
