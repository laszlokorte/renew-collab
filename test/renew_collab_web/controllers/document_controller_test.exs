defmodule RenewCollabWeb.DocumentControllerTest do
  use RenewCollabWeb.ConnCase

  import RenewCollab.RenewFixtures

  alias RenewCollab.Renew.Document

  @create_attrs %{
    name: "some name",
    kind: "some kind"
  }
  @update_attrs %{
    name: "some updated name",
    kind: "some updated kind"
  }
  @invalid_attrs %{name: nil, kind: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all document", %{conn: conn} do
      conn = get(conn, ~p"/api/document")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create document" do
    test "renders document when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/document", document: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/document/#{id}")

      assert %{
               "id" => ^id,
               "kind" => "some kind",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/document", document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update document" do
    setup [:create_document]

    test "renders document when data is valid", %{
      conn: conn,
      document: %Document{id: id} = document
    } do
      conn = put(conn, ~p"/api/document/#{document}", document: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/document/#{id}")

      assert %{
               "id" => ^id,
               "kind" => "some updated kind",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, document: document} do
      conn = put(conn, ~p"/api/document/#{document}", document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete document" do
    setup [:create_document]

    test "deletes chosen document", %{conn: conn, document: document} do
      conn = delete(conn, ~p"/api/document/#{document}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/document/#{document}")
      end
    end
  end

  defp create_document(_) do
    document = document_fixture()
    %{document: document}
  end
end
