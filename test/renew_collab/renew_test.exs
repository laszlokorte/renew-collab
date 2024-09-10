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

  describe "element_parenthood" do
    alias RenewCollab.Renew.ElementParenthood

    import RenewCollab.RenewFixtures

    @invalid_attrs %{depth: nil}

    test "list_element_parenthood/0 returns all element_parenthood" do
      element_parenthood = element_parenthood_fixture()
      assert Renew.list_element_parenthood() == [element_parenthood]
    end

    test "get_element_parenthood!/1 returns the element_parenthood with given id" do
      element_parenthood = element_parenthood_fixture()
      assert Renew.get_element_parenthood!(element_parenthood.id) == element_parenthood
    end

    test "create_element_parenthood/1 with valid data creates a element_parenthood" do
      valid_attrs = %{depth: 42}

      assert {:ok, %ElementParenthood{} = element_parenthood} =
               Renew.create_element_parenthood(valid_attrs)

      assert element_parenthood.depth == 42
    end

    test "create_element_parenthood/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element_parenthood(@invalid_attrs)
    end

    test "update_element_parenthood/2 with valid data updates the element_parenthood" do
      element_parenthood = element_parenthood_fixture()
      update_attrs = %{depth: 43}

      assert {:ok, %ElementParenthood{} = element_parenthood} =
               Renew.update_element_parenthood(element_parenthood, update_attrs)

      assert element_parenthood.depth == 43
    end

    test "update_element_parenthood/2 with invalid data returns error changeset" do
      element_parenthood = element_parenthood_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_parenthood(element_parenthood, @invalid_attrs)

      assert element_parenthood == Renew.get_element_parenthood!(element_parenthood.id)
    end

    test "delete_element_parenthood/1 deletes the element_parenthood" do
      element_parenthood = element_parenthood_fixture()
      assert {:ok, %ElementParenthood{}} = Renew.delete_element_parenthood(element_parenthood)

      assert_raise Ecto.NoResultsError, fn ->
        Renew.get_element_parenthood!(element_parenthood.id)
      end
    end

    test "change_element_parenthood/1 returns a element_parenthood changeset" do
      element_parenthood = element_parenthood_fixture()
      assert %Ecto.Changeset{} = Renew.change_element_parenthood(element_parenthood)
    end
  end

  describe "element_box" do
    alias RenewCollab.Renew.ElementBox

    import RenewCollab.RenewFixtures

    @invalid_attrs %{width: nil, height: nil}

    test "list_element_box/0 returns all element_box" do
      element_box = element_box_fixture()
      assert Renew.list_element_box() == [element_box]
    end

    test "get_element_box!/1 returns the element_box with given id" do
      element_box = element_box_fixture()
      assert Renew.get_element_box!(element_box.id) == element_box
    end

    test "create_element_box/1 with valid data creates a element_box" do
      valid_attrs = %{width: 120.5, height: 120.5}

      assert {:ok, %ElementBox{} = element_box} = Renew.create_element_box(valid_attrs)
      assert element_box.width == 120.5
      assert element_box.height == 120.5
    end

    test "create_element_box/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element_box(@invalid_attrs)
    end

    test "update_element_box/2 with valid data updates the element_box" do
      element_box = element_box_fixture()
      update_attrs = %{width: 456.7, height: 456.7}

      assert {:ok, %ElementBox{} = element_box} =
               Renew.update_element_box(element_box, update_attrs)

      assert element_box.width == 456.7
      assert element_box.height == 456.7
    end

    test "update_element_box/2 with invalid data returns error changeset" do
      element_box = element_box_fixture()
      assert {:error, %Ecto.Changeset{}} = Renew.update_element_box(element_box, @invalid_attrs)
      assert element_box == Renew.get_element_box!(element_box.id)
    end

    test "delete_element_box/1 deletes the element_box" do
      element_box = element_box_fixture()
      assert {:ok, %ElementBox{}} = Renew.delete_element_box(element_box)
      assert_raise Ecto.NoResultsError, fn -> Renew.get_element_box!(element_box.id) end
    end

    test "change_element_box/1 returns a element_box changeset" do
      element_box = element_box_fixture()
      assert %Ecto.Changeset{} = Renew.change_element_box(element_box)
    end
  end

  describe "element_text" do
    alias RenewCollab.Renew.ElementText

    import RenewCollab.RenewFixtures

    @invalid_attrs %{body: nil}

    test "list_element_text/0 returns all element_text" do
      element_text = element_text_fixture()
      assert Renew.list_element_text() == [element_text]
    end

    test "get_element_text!/1 returns the element_text with given id" do
      element_text = element_text_fixture()
      assert Renew.get_element_text!(element_text.id) == element_text
    end

    test "create_element_text/1 with valid data creates a element_text" do
      valid_attrs = %{body: "some body"}

      assert {:ok, %ElementText{} = element_text} = Renew.create_element_text(valid_attrs)
      assert element_text.body == "some body"
    end

    test "create_element_text/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element_text(@invalid_attrs)
    end

    test "update_element_text/2 with valid data updates the element_text" do
      element_text = element_text_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %ElementText{} = element_text} =
               Renew.update_element_text(element_text, update_attrs)

      assert element_text.body == "some updated body"
    end

    test "update_element_text/2 with invalid data returns error changeset" do
      element_text = element_text_fixture()
      assert {:error, %Ecto.Changeset{}} = Renew.update_element_text(element_text, @invalid_attrs)
      assert element_text == Renew.get_element_text!(element_text.id)
    end

    test "delete_element_text/1 deletes the element_text" do
      element_text = element_text_fixture()
      assert {:ok, %ElementText{}} = Renew.delete_element_text(element_text)
      assert_raise Ecto.NoResultsError, fn -> Renew.get_element_text!(element_text.id) end
    end

    test "change_element_text/1 returns a element_text changeset" do
      element_text = element_text_fixture()
      assert %Ecto.Changeset{} = Renew.change_element_text(element_text)
    end
  end

  describe "element_connection" do
    alias RenewCollab.Renew.ElementConnection

    import RenewCollab.RenewFixtures

    @invalid_attrs %{source_x: nil, source_y: nil, target_x: nil, target_y: nil}

    test "list_element_connection/0 returns all element_connection" do
      element_connection = element_connection_fixture()
      assert Renew.list_element_connection() == [element_connection]
    end

    test "get_element_connection!/1 returns the element_connection with given id" do
      element_connection = element_connection_fixture()
      assert Renew.get_element_connection!(element_connection.id) == element_connection
    end

    test "create_element_connection/1 with valid data creates a element_connection" do
      valid_attrs = %{source_x: 120.5, source_y: 120.5, target_x: 120.5, target_y: 120.5}

      assert {:ok, %ElementConnection{} = element_connection} =
               Renew.create_element_connection(valid_attrs)

      assert element_connection.source_x == 120.5
      assert element_connection.source_y == 120.5
      assert element_connection.target_x == 120.5
      assert element_connection.target_y == 120.5
    end

    test "create_element_connection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element_connection(@invalid_attrs)
    end

    test "update_element_connection/2 with valid data updates the element_connection" do
      element_connection = element_connection_fixture()
      update_attrs = %{source_x: 456.7, source_y: 456.7, target_x: 456.7, target_y: 456.7}

      assert {:ok, %ElementConnection{} = element_connection} =
               Renew.update_element_connection(element_connection, update_attrs)

      assert element_connection.source_x == 456.7
      assert element_connection.source_y == 456.7
      assert element_connection.target_x == 456.7
      assert element_connection.target_y == 456.7
    end

    test "update_element_connection/2 with invalid data returns error changeset" do
      element_connection = element_connection_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_connection(element_connection, @invalid_attrs)

      assert element_connection == Renew.get_element_connection!(element_connection.id)
    end

    test "delete_element_connection/1 deletes the element_connection" do
      element_connection = element_connection_fixture()
      assert {:ok, %ElementConnection{}} = Renew.delete_element_connection(element_connection)

      assert_raise Ecto.NoResultsError, fn ->
        Renew.get_element_connection!(element_connection.id)
      end
    end

    test "change_element_connection/1 returns a element_connection changeset" do
      element_connection = element_connection_fixture()
      assert %Ecto.Changeset{} = Renew.change_element_connection(element_connection)
    end
  end

  describe "element_socket" do
    alias RenewCollab.Renew.ElementSocket

    import RenewCollab.RenewFixtures

    @invalid_attrs %{name: nil, kind: nil}

    test "list_element_socket/0 returns all element_socket" do
      element_socket = element_socket_fixture()
      assert Renew.list_element_socket() == [element_socket]
    end

    test "get_element_socket!/1 returns the element_socket with given id" do
      element_socket = element_socket_fixture()
      assert Renew.get_element_socket!(element_socket.id) == element_socket
    end

    test "create_element_socket/1 with valid data creates a element_socket" do
      valid_attrs = %{name: "some name", kind: "some kind"}

      assert {:ok, %ElementSocket{} = element_socket} = Renew.create_element_socket(valid_attrs)
      assert element_socket.name == "some name"
      assert element_socket.kind == "some kind"
    end

    test "create_element_socket/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element_socket(@invalid_attrs)
    end

    test "update_element_socket/2 with valid data updates the element_socket" do
      element_socket = element_socket_fixture()
      update_attrs = %{name: "some updated name", kind: "some updated kind"}

      assert {:ok, %ElementSocket{} = element_socket} =
               Renew.update_element_socket(element_socket, update_attrs)

      assert element_socket.name == "some updated name"
      assert element_socket.kind == "some updated kind"
    end

    test "update_element_socket/2 with invalid data returns error changeset" do
      element_socket = element_socket_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_socket(element_socket, @invalid_attrs)

      assert element_socket == Renew.get_element_socket!(element_socket.id)
    end

    test "delete_element_socket/1 deletes the element_socket" do
      element_socket = element_socket_fixture()
      assert {:ok, %ElementSocket{}} = Renew.delete_element_socket(element_socket)
      assert_raise Ecto.NoResultsError, fn -> Renew.get_element_socket!(element_socket.id) end
    end

    test "change_element_socket/1 returns a element_socket changeset" do
      element_socket = element_socket_fixture()
      assert %Ecto.Changeset{} = Renew.change_element_socket(element_socket)
    end
  end

  describe "element_connection_waypoint" do
    alias RenewCollab.Renew.ElementConnectionWaypoint

    import RenewCollab.RenewFixtures

    @invalid_attrs %{sort: nil, position_x: nil, position_y: nil}

    test "list_element_connection_waypoint/0 returns all element_connection_waypoint" do
      element_connection_waypoint = element_connection_waypoint_fixture()
      assert Renew.list_element_connection_waypoint() == [element_connection_waypoint]
    end

    test "get_element_connection_waypoint!/1 returns the element_connection_waypoint with given id" do
      element_connection_waypoint = element_connection_waypoint_fixture()

      assert Renew.get_element_connection_waypoint!(element_connection_waypoint.id) ==
               element_connection_waypoint
    end

    test "create_element_connection_waypoint/1 with valid data creates a element_connection_waypoint" do
      valid_attrs = %{sort: 42, position_x: 120.5, position_y: 120.5}

      assert {:ok, %ElementConnectionWaypoint{} = element_connection_waypoint} =
               Renew.create_element_connection_waypoint(valid_attrs)

      assert element_connection_waypoint.sort == 42
      assert element_connection_waypoint.position_x == 120.5
      assert element_connection_waypoint.position_y == 120.5
    end

    test "create_element_connection_waypoint/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Renew.create_element_connection_waypoint(@invalid_attrs)
    end

    test "update_element_connection_waypoint/2 with valid data updates the element_connection_waypoint" do
      element_connection_waypoint = element_connection_waypoint_fixture()
      update_attrs = %{sort: 43, position_x: 456.7, position_y: 456.7}

      assert {:ok, %ElementConnectionWaypoint{} = element_connection_waypoint} =
               Renew.update_element_connection_waypoint(element_connection_waypoint, update_attrs)

      assert element_connection_waypoint.sort == 43
      assert element_connection_waypoint.position_x == 456.7
      assert element_connection_waypoint.position_y == 456.7
    end

    test "update_element_connection_waypoint/2 with invalid data returns error changeset" do
      element_connection_waypoint = element_connection_waypoint_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_connection_waypoint(
                 element_connection_waypoint,
                 @invalid_attrs
               )

      assert element_connection_waypoint ==
               Renew.get_element_connection_waypoint!(element_connection_waypoint.id)
    end

    test "delete_element_connection_waypoint/1 deletes the element_connection_waypoint" do
      element_connection_waypoint = element_connection_waypoint_fixture()

      assert {:ok, %ElementConnectionWaypoint{}} =
               Renew.delete_element_connection_waypoint(element_connection_waypoint)

      assert_raise Ecto.NoResultsError, fn ->
        Renew.get_element_connection_waypoint!(element_connection_waypoint.id)
      end
    end

    test "change_element_connection_waypoint/1 returns a element_connection_waypoint changeset" do
      element_connection_waypoint = element_connection_waypoint_fixture()

      assert %Ecto.Changeset{} =
               Renew.change_element_connection_waypoint(element_connection_waypoint)
    end
  end

  describe "element_connection_source_bond" do
    alias RenewCollab.Renew.ElementConnectionSourceBond

    import RenewCollab.RenewFixtures

    @invalid_attrs %{}

    test "list_element_connection_source_bond/0 returns all element_connection_source_bond" do
      element_connection_source_bond = element_connection_source_bond_fixture()
      assert Renew.list_element_connection_source_bond() == [element_connection_source_bond]
    end

    test "get_element_connection_source_bond!/1 returns the element_connection_source_bond with given id" do
      element_connection_source_bond = element_connection_source_bond_fixture()

      assert Renew.get_element_connection_source_bond!(element_connection_source_bond.id) ==
               element_connection_source_bond
    end

    test "create_element_connection_source_bond/1 with valid data creates a element_connection_source_bond" do
      valid_attrs = %{}

      assert {:ok, %ElementConnectionSourceBond{} = element_connection_source_bond} =
               Renew.create_element_connection_source_bond(valid_attrs)
    end

    test "create_element_connection_source_bond/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Renew.create_element_connection_source_bond(@invalid_attrs)
    end

    test "update_element_connection_source_bond/2 with valid data updates the element_connection_source_bond" do
      element_connection_source_bond = element_connection_source_bond_fixture()
      update_attrs = %{}

      assert {:ok, %ElementConnectionSourceBond{} = element_connection_source_bond} =
               Renew.update_element_connection_source_bond(
                 element_connection_source_bond,
                 update_attrs
               )
    end

    test "update_element_connection_source_bond/2 with invalid data returns error changeset" do
      element_connection_source_bond = element_connection_source_bond_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_connection_source_bond(
                 element_connection_source_bond,
                 @invalid_attrs
               )

      assert element_connection_source_bond ==
               Renew.get_element_connection_source_bond!(element_connection_source_bond.id)
    end

    test "delete_element_connection_source_bond/1 deletes the element_connection_source_bond" do
      element_connection_source_bond = element_connection_source_bond_fixture()

      assert {:ok, %ElementConnectionSourceBond{}} =
               Renew.delete_element_connection_source_bond(element_connection_source_bond)

      assert_raise Ecto.NoResultsError, fn ->
        Renew.get_element_connection_source_bond!(element_connection_source_bond.id)
      end
    end

    test "change_element_connection_source_bond/1 returns a element_connection_source_bond changeset" do
      element_connection_source_bond = element_connection_source_bond_fixture()

      assert %Ecto.Changeset{} =
               Renew.change_element_connection_source_bond(element_connection_source_bond)
    end
  end

  describe "element_connection_target_bond" do
    alias RenewCollab.Renew.ElementConnectionTargetBond

    import RenewCollab.RenewFixtures

    @invalid_attrs %{}

    test "list_element_connection_target_bond/0 returns all element_connection_target_bond" do
      element_connection_target_bond = element_connection_target_bond_fixture()
      assert Renew.list_element_connection_target_bond() == [element_connection_target_bond]
    end

    test "get_element_connection_target_bond!/1 returns the element_connection_target_bond with given id" do
      element_connection_target_bond = element_connection_target_bond_fixture()

      assert Renew.get_element_connection_target_bond!(element_connection_target_bond.id) ==
               element_connection_target_bond
    end

    test "create_element_connection_target_bond/1 with valid data creates a element_connection_target_bond" do
      valid_attrs = %{}

      assert {:ok, %ElementConnectionTargetBond{} = element_connection_target_bond} =
               Renew.create_element_connection_target_bond(valid_attrs)
    end

    test "create_element_connection_target_bond/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Renew.create_element_connection_target_bond(@invalid_attrs)
    end

    test "update_element_connection_target_bond/2 with valid data updates the element_connection_target_bond" do
      element_connection_target_bond = element_connection_target_bond_fixture()
      update_attrs = %{}

      assert {:ok, %ElementConnectionTargetBond{} = element_connection_target_bond} =
               Renew.update_element_connection_target_bond(
                 element_connection_target_bond,
                 update_attrs
               )
    end

    test "update_element_connection_target_bond/2 with invalid data returns error changeset" do
      element_connection_target_bond = element_connection_target_bond_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_connection_target_bond(
                 element_connection_target_bond,
                 @invalid_attrs
               )

      assert element_connection_target_bond ==
               Renew.get_element_connection_target_bond!(element_connection_target_bond.id)
    end

    test "delete_element_connection_target_bond/1 deletes the element_connection_target_bond" do
      element_connection_target_bond = element_connection_target_bond_fixture()

      assert {:ok, %ElementConnectionTargetBond{}} =
               Renew.delete_element_connection_target_bond(element_connection_target_bond)

      assert_raise Ecto.NoResultsError, fn ->
        Renew.get_element_connection_target_bond!(element_connection_target_bond.id)
      end
    end

    test "change_element_connection_target_bond/1 returns a element_connection_target_bond changeset" do
      element_connection_target_bond = element_connection_target_bond_fixture()

      assert %Ecto.Changeset{} =
               Renew.change_element_connection_target_bond(element_connection_target_bond)
    end
  end

  describe "element_style" do
    alias RenewCollab.Renew.ElementStyle

    import RenewCollab.RenewFixtures

    @invalid_attrs %{opacity: nil, background_color: nil, border_color: nil, border_width: nil}

    test "list_element_style/0 returns all element_style" do
      element_style = element_style_fixture()
      assert Renew.list_element_style() == [element_style]
    end

    test "get_element_style!/1 returns the element_style with given id" do
      element_style = element_style_fixture()
      assert Renew.get_element_style!(element_style.id) == element_style
    end

    test "create_element_style/1 with valid data creates a element_style" do
      valid_attrs = %{
        opacity: 120.5,
        background_color: "some background_color",
        border_color: "some border_color",
        border_width: "some border_width"
      }

      assert {:ok, %ElementStyle{} = element_style} = Renew.create_element_style(valid_attrs)
      assert element_style.opacity == 120.5
      assert element_style.background_color == "some background_color"
      assert element_style.border_color == "some border_color"
      assert element_style.border_width == "some border_width"
    end

    test "create_element_style/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element_style(@invalid_attrs)
    end

    test "update_element_style/2 with valid data updates the element_style" do
      element_style = element_style_fixture()

      update_attrs = %{
        opacity: 456.7,
        background_color: "some updated background_color",
        border_color: "some updated border_color",
        border_width: "some updated border_width"
      }

      assert {:ok, %ElementStyle{} = element_style} =
               Renew.update_element_style(element_style, update_attrs)

      assert element_style.opacity == 456.7
      assert element_style.background_color == "some updated background_color"
      assert element_style.border_color == "some updated border_color"
      assert element_style.border_width == "some updated border_width"
    end

    test "update_element_style/2 with invalid data returns error changeset" do
      element_style = element_style_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_style(element_style, @invalid_attrs)

      assert element_style == Renew.get_element_style!(element_style.id)
    end

    test "delete_element_style/1 deletes the element_style" do
      element_style = element_style_fixture()
      assert {:ok, %ElementStyle{}} = Renew.delete_element_style(element_style)
      assert_raise Ecto.NoResultsError, fn -> Renew.get_element_style!(element_style.id) end
    end

    test "change_element_style/1 returns a element_style changeset" do
      element_style = element_style_fixture()
      assert %Ecto.Changeset{} = Renew.change_element_style(element_style)
    end
  end

  describe "element_connection_style" do
    alias RenewCollab.Renew.ElementConnectionStyle

    import RenewCollab.RenewFixtures

    @invalid_attrs %{
      stroke_width: nil,
      stroke_color: nil,
      stroke_joint: nil,
      stroke_cap: nil,
      stroke_dash_array: nil,
      source_tip: nil,
      target_tip: nil,
      smoothness: nil
    }

    test "list_element_connection_style/0 returns all element_connection_style" do
      element_connection_style = element_connection_style_fixture()
      assert Renew.list_element_connection_style() == [element_connection_style]
    end

    test "get_element_connection_style!/1 returns the element_connection_style with given id" do
      element_connection_style = element_connection_style_fixture()

      assert Renew.get_element_connection_style!(element_connection_style.id) ==
               element_connection_style
    end

    test "create_element_connection_style/1 with valid data creates a element_connection_style" do
      valid_attrs = %{
        stroke_width: "some stroke_width",
        stroke_color: "some stroke_color",
        stroke_joint: "some stroke_joint",
        stroke_cap: "some stroke_cap",
        stroke_dash_array: "some stroke_dash_array",
        source_tip: "some source_tip",
        target_tip: "some target_tip",
        smoothness: "some smoothness"
      }

      assert {:ok, %ElementConnectionStyle{} = element_connection_style} =
               Renew.create_element_connection_style(valid_attrs)

      assert element_connection_style.stroke_width == "some stroke_width"
      assert element_connection_style.stroke_color == "some stroke_color"
      assert element_connection_style.stroke_joint == "some stroke_joint"
      assert element_connection_style.stroke_cap == "some stroke_cap"
      assert element_connection_style.stroke_dash_array == "some stroke_dash_array"
      assert element_connection_style.source_tip == "some source_tip"
      assert element_connection_style.target_tip == "some target_tip"
      assert element_connection_style.smoothness == "some smoothness"
    end

    test "create_element_connection_style/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element_connection_style(@invalid_attrs)
    end

    test "update_element_connection_style/2 with valid data updates the element_connection_style" do
      element_connection_style = element_connection_style_fixture()

      update_attrs = %{
        stroke_width: "some updated stroke_width",
        stroke_color: "some updated stroke_color",
        stroke_joint: "some updated stroke_joint",
        stroke_cap: "some updated stroke_cap",
        stroke_dash_array: "some updated stroke_dash_array",
        source_tip: "some updated source_tip",
        target_tip: "some updated target_tip",
        smoothness: "some updated smoothness"
      }

      assert {:ok, %ElementConnectionStyle{} = element_connection_style} =
               Renew.update_element_connection_style(element_connection_style, update_attrs)

      assert element_connection_style.stroke_width == "some updated stroke_width"
      assert element_connection_style.stroke_color == "some updated stroke_color"
      assert element_connection_style.stroke_joint == "some updated stroke_joint"
      assert element_connection_style.stroke_cap == "some updated stroke_cap"
      assert element_connection_style.stroke_dash_array == "some updated stroke_dash_array"
      assert element_connection_style.source_tip == "some updated source_tip"
      assert element_connection_style.target_tip == "some updated target_tip"
      assert element_connection_style.smoothness == "some updated smoothness"
    end

    test "update_element_connection_style/2 with invalid data returns error changeset" do
      element_connection_style = element_connection_style_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_connection_style(element_connection_style, @invalid_attrs)

      assert element_connection_style ==
               Renew.get_element_connection_style!(element_connection_style.id)
    end

    test "delete_element_connection_style/1 deletes the element_connection_style" do
      element_connection_style = element_connection_style_fixture()

      assert {:ok, %ElementConnectionStyle{}} =
               Renew.delete_element_connection_style(element_connection_style)

      assert_raise Ecto.NoResultsError, fn ->
        Renew.get_element_connection_style!(element_connection_style.id)
      end
    end

    test "change_element_connection_style/1 returns a element_connection_style changeset" do
      element_connection_style = element_connection_style_fixture()
      assert %Ecto.Changeset{} = Renew.change_element_connection_style(element_connection_style)
    end
  end

  describe "element_text_style" do
    alias RenewCollab.Renew.ElementTextStyle

    import RenewCollab.RenewFixtures

    @invalid_attrs %{
      italic: nil,
      underline: nil,
      alignment: nil,
      font_size: nil,
      font_family: nil,
      bold: nil,
      text_color: nil
    }

    test "list_element_text_style/0 returns all element_text_style" do
      element_text_style = element_text_style_fixture()
      assert Renew.list_element_text_style() == [element_text_style]
    end

    test "get_element_text_style!/1 returns the element_text_style with given id" do
      element_text_style = element_text_style_fixture()
      assert Renew.get_element_text_style!(element_text_style.id) == element_text_style
    end

    test "create_element_text_style/1 with valid data creates a element_text_style" do
      valid_attrs = %{
        italic: true,
        underline: true,
        alignment: :left,
        font_size: 120.5,
        font_family: "some font_family",
        bold: true,
        text_color: "some text_color"
      }

      assert {:ok, %ElementTextStyle{} = element_text_style} =
               Renew.create_element_text_style(valid_attrs)

      assert element_text_style.italic == true
      assert element_text_style.underline == true
      assert element_text_style.alignment == :left
      assert element_text_style.font_size == 120.5
      assert element_text_style.font_family == "some font_family"
      assert element_text_style.bold == true
      assert element_text_style.text_color == "some text_color"
    end

    test "create_element_text_style/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Renew.create_element_text_style(@invalid_attrs)
    end

    test "update_element_text_style/2 with valid data updates the element_text_style" do
      element_text_style = element_text_style_fixture()

      update_attrs = %{
        italic: false,
        underline: false,
        alignment: :center,
        font_size: 456.7,
        font_family: "some updated font_family",
        bold: false,
        text_color: "some updated text_color"
      }

      assert {:ok, %ElementTextStyle{} = element_text_style} =
               Renew.update_element_text_style(element_text_style, update_attrs)

      assert element_text_style.italic == false
      assert element_text_style.underline == false
      assert element_text_style.alignment == :center
      assert element_text_style.font_size == 456.7
      assert element_text_style.font_family == "some updated font_family"
      assert element_text_style.bold == false
      assert element_text_style.text_color == "some updated text_color"
    end

    test "update_element_text_style/2 with invalid data returns error changeset" do
      element_text_style = element_text_style_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Renew.update_element_text_style(element_text_style, @invalid_attrs)

      assert element_text_style == Renew.get_element_text_style!(element_text_style.id)
    end

    test "delete_element_text_style/1 deletes the element_text_style" do
      element_text_style = element_text_style_fixture()
      assert {:ok, %ElementTextStyle{}} = Renew.delete_element_text_style(element_text_style)

      assert_raise Ecto.NoResultsError, fn ->
        Renew.get_element_text_style!(element_text_style.id)
      end
    end

    test "change_element_text_style/1 returns a element_text_style changeset" do
      element_text_style = element_text_style_fixture()
      assert %Ecto.Changeset{} = Renew.change_element_text_style(element_text_style)
    end
  end
end
