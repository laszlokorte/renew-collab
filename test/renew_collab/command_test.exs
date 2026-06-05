defmodule RenewCollab.CommandTest do
  use RenewCollab.DataCase

  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Commands.InsertDocument
  alias RenewCollab.DocumentCommander
  alias RenewCollab.Document.Document
  alias RenewCollab.Element.Text
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Commands.MoveLayerRelative

  describe "insert_document" do
    test "aligns source document bounds with the requested position" do
      source_doc =
        %Document{}
        |> Document.changeset(%{name: "Source", kind: "test"})
        |> Repo.insert!()

      target_doc =
        %Document{}
        |> Document.changeset(%{name: "Target", kind: "test"})
        |> Repo.insert!()

      %Layer{}
      |> Layer.changeset(%{
        document_id: source_doc.id,
        z_index: 1,
        hidden: false,
        semantic_tag: "CH.ifa.draw.figures.RectangleFigure",
        box: %{
          position_x: -50.0,
          position_y: 100.0,
          width: 20.0,
          height: 30.0
        }
      })
      |> Repo.insert!()

      %Layer{}
      |> Layer.changeset(%{
        document_id: source_doc.id,
        z_index: 2,
        hidden: false,
        semantic_tag: "CH.ifa.draw.figures.TextFigure",
        text: %{
          body: "label",
          position_x: 10.0,
          position_y: 150.0,
          size_hint: %{
            position_x: 10.0,
            position_y: 135.0,
            width: 80.0,
            height: 25.0
          }
        }
      })
      |> Repo.insert!()

      %Layer{}
      |> Layer.changeset(%{
        document_id: source_doc.id,
        z_index: 3,
        hidden: false,
        semantic_tag: "CH.ifa.draw.figures.TextFigure",
        text: %{
          body: "missing\n\nhint",
          position_x: -20.0,
          position_y: 200.0,
          style: %{
            blank_lines: true,
            font_size: 12.0
          }
        }
      })
      |> Repo.insert!()

      {:ok, _} =
        %{
          source_document_id: source_doc.id,
          target_document_id: target_doc.id,
          position: {25.0, 35.0}
        }
        |> InsertDocument.new()
        |> DocumentCommander.run_document_command_sync(false)

      box =
        from(l in Layer,
          join: b in assoc(l, :box),
          where: l.document_id == ^target_doc.id,
          select: b
        )
        |> Repo.one!()

      text =
        from(l in Layer,
          join: t in assoc(l, :text),
          where: l.document_id == ^target_doc.id,
          where: t.body == "label",
          select: t
        )
        |> Repo.one!()
        |> Repo.preload(:size_hint)

      missing_hint_text =
        from(l in Layer,
          join: t in assoc(l, :text),
          where: l.document_id == ^target_doc.id,
          where: t.body == "missing\n\nhint",
          select: t
        )
        |> Repo.one!()
        |> Repo.preload(:size_hint)

      assert_in_delta box.position_x, 25.0, 0.0001
      assert_in_delta box.position_y, 35.0, 0.0001
      assert_in_delta text.position_x, 85.0, 0.0001
      assert_in_delta text.position_y, 85.0, 0.0001
      assert_in_delta text.size_hint.position_x, 85.0, 0.0001
      assert_in_delta text.size_hint.position_y, 85.0, 0.0001
      assert_in_delta missing_hint_text.position_x, 55.0, 0.0001
      assert_in_delta missing_hint_text.position_y, 135.0, 0.0001
      assert_in_delta missing_hint_text.size_hint.position_x, 55.0, 0.0001
      assert_in_delta missing_hint_text.size_hint.position_y, 135.0, 0.0001
      assert missing_hint_text.size_hint.height > 12.0
    end
  end

  describe "move_layer_relative" do
    test "does not directly move text linked to a connected edge" do
      RenewCollab.DocumentFixtures.document_fixture()

      source_layer_id = "47258301-e3ea-472f-ba0b-0fc8cc0c4a1d"
      edge_layer_id = "dd3df027-1e28-4e32-98bd-37969ef8b46f"
      edge_text_layer_id = "6feef6e1-221c-4278-a7b0-02c7355c2d85"

      document_id =
        from(l in Layer, where: l.id == ^source_layer_id, select: l.document_id) |> Repo.one!()

      %Layer{}
      |> Layer.changeset(%{
        id: edge_text_layer_id,
        document_id: document_id,
        z_index: 99,
        hidden: false,
        semantic_tag: "CH.ifa.draw.figures.TextFigure",
        text: %{
          body: "edge label",
          position_x: 100.0,
          position_y: 100.0
        }
      })
      |> Repo.insert!()

      %LayerParenthood{}
      |> LayerParenthood.changeset(%{
        document_id: document_id,
        ancestor_id: edge_text_layer_id,
        descendant_id: edge_text_layer_id,
        depth: 0
      })
      |> Repo.insert!()

      %Hyperlink{}
      |> Hyperlink.changeset(%{
        source_layer_id: edge_text_layer_id,
        target_layer_id: edge_layer_id
      })
      |> Repo.insert!()

      {:ok, _} =
        %{document_id: document_id, layer_id: source_layer_id, dx: 100.0, dy: 0.0}
        |> MoveLayerRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      text = from(t in Text, where: t.layer_id == ^edge_text_layer_id) |> Repo.one!()

      assert text.position_x > 100.0
      assert text.position_x < 200.0
    end
  end
end
