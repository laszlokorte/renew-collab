defmodule RenewCollab.RenewTest do
  use RenewCollab.DataCase

  alias RenewCollab.Renew

  describe "document" do
    alias RenewCollab.Renew.Document

    import RenewCollab.RenewFixtures

    @invalid_attrs %{name: nil, kind: nil}

    test "list_documents/0 returns all document" do
      document = document_fixture()
      assert Renew.list_documents() == [document]
    end

    test "get_document!/1 returns the document with given id" do
      document = document_fixture()
      assert Renew.get_document!(document.id) == document
    end

    test "create_document/1 with valid data creates a document" do
      valid_attrs = %{name: "some name", kind: "some kind"}

      assert {:ok, %Document{} = document} = Renew.create_document(valid_attrs)
      assert document.name == "some name"
      assert document.kind == "some kind"
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_document(@invalid_attrs)
    end

    test "update_document/2 with valid data updates the document" do
      document = document_fixture()
      update_attrs = %{name: "some updated name", kind: "some updated kind"}

      assert {:ok, %Document{} = document} = Renew.update_document(document, update_attrs)
      assert document.name == "some updated name"
      assert document.kind == "some updated kind"
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = document_fixture()
      assert {:error, %Ecto.Changeset{}} = Renew.update_document(document, @invalid_attrs)
      assert document == Renew.get_document!(document.id)
    end

    test "delete_document/1 deletes the document" do
      document = document_fixture()
      assert {:ok, %Document{}} = Renew.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Renew.get_document!(document.id) end
    end

    test "change_document/1 returns a document changeset" do
      document = document_fixture()
      assert %Ecto.Changeset{} = Renew.change_document(document)
    end
  end

  describe "element" do
    alias RenewCollab.Renew.Element

    import RenewCollab.RenewFixtures

    @invalid_attrs %{z_index: nil, position_x: nil, position_y: nil}

    test "list_elements/0 returns all element" do
      element = element_fixture()
      assert Renew.list_elements() == [element]
    end

    test "get_element!/1 returns the element with given id" do
      element = element_fixture()
      assert Renew.get_element!(element.id) == element
    end

    test "create_element/1 with valid data creates a element" do
      valid_attrs = %{z_index: 42, position_x: 120.5, position_y: 120.5}

      assert {:ok, %Element{} = element} = Renew.create_element(valid_attrs)
      assert element.z_index == 42
      assert element.position_x == 120.5
      assert element.position_y == 120.5
    end

    test "create_element/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element(@invalid_attrs)
    end

    test "update_element/2 with valid data updates the element" do
      element = element_fixture()
      update_attrs = %{z_index: 43, position_x: 456.7, position_y: 456.7}

      assert {:ok, %Element{} = element} = Renew.update_element(element, update_attrs)
      assert element.z_index == 43
      assert element.position_x == 456.7
      assert element.position_y == 456.7
    end

    test "update_element/2 with invalid data returns error changeset" do
      element = element_fixture()
      assert {:error, %Ecto.Changeset{}} = Renew.update_element(element, @invalid_attrs)
      assert element == Renew.get_element!(element.id)
    end

    test "delete_element/1 deletes the element" do
      element = element_fixture()
      assert {:ok, %Element{}} = Renew.delete_element(element)
      assert_raise Ecto.NoResultsError, fn -> Renew.get_element!(element.id) end
    end

    test "change_element/1 returns a element changeset" do
      element = element_fixture()
      assert %Ecto.Changeset{} = Renew.change_element(element)
    end
  end
end
