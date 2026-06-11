defmodule RenewCollab.CommandTest do
  use RenewCollab.DataCase

  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Commands.CreateParentLayer
  alias RenewCollab.Commands.InsertDocument
  alias RenewCollab.Commands.InsertLayerClipboard
  alias RenewCollab.Commands.InsertTransientDocument
  alias RenewCollab.Commands.ReorderLayersRelative
  alias RenewCollab.Connection.Bond
  alias RenewCollab.DocumentCommander
  alias RenewCollab.Document.Document
  alias RenewCollab.Element.Text
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Commands.MoveLayerRelative

  defp test_document(name) do
    %Document{}
    |> Document.changeset(%{name: name, kind: "test"})
    |> Repo.insert!()
  end

  defp test_layer(document, z_index) do
    %Layer{}
    |> Layer.changeset(%{
      document_id: document.id,
      z_index: z_index,
      hidden: false
    })
    |> Repo.insert!()
  end

  defp parent_layer(document, parent, child) do
    parent_layers(document, parent, [child])
  end

  defp self_layer(document, layer) do
    insert_parenthood(document, layer, layer, 0)
  end

  defp parent_layers(document, parent, children) do
    self_layer(document, parent)

    Enum.each(children, fn child ->
      self_layer(document, child)
      insert_parenthood(document, parent, child, 1)
    end)
  end

  defp insert_parenthood(document, ancestor, descendant, depth) do
    %LayerParenthood{}
    |> LayerParenthood.changeset(%{
      document_id: document.id,
      ancestor_id: ancestor.id,
      descendant_id: descendant.id,
      depth: depth
    })
    |> Repo.insert!()
  end

  defp top_level_layer_ids(document) do
    from(l in Layer,
      left_join: p in LayerParenthood,
      on: p.descendant_id == l.id and p.depth == 1,
      where: l.document_id == ^document.id and is_nil(p.id),
      order_by: [asc: l.z_index],
      select: l.id
    )
    |> Repo.all()
  end

  defp top_level_layer_z_indexes(document) do
    from(l in Layer,
      left_join: p in LayerParenthood,
      on: p.descendant_id == l.id and p.depth == 1,
      where: l.document_id == ^document.id and is_nil(p.id),
      order_by: [asc: l.z_index],
      select: l.z_index
    )
    |> Repo.all()
  end

  defp direct_parent_id(child) do
    from(p in LayerParenthood,
      where: p.descendant_id == ^child.id and p.depth == 1,
      select: p.ancestor_id
    )
    |> Repo.one()
  end

  defp direct_child_ids(parent) do
    from(l in Layer,
      join: p in LayerParenthood,
      on: p.descendant_id == l.id and p.ancestor_id == ^parent.id and p.depth == 1,
      order_by: [asc: l.z_index],
      select: l.id
    )
    |> Repo.all()
  end

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

  describe "insert_transient_document" do
    test "preserves finite automata state decorations during import" do
      RenewCollab.SymbolFixtures.shape_fixture()

      rnw = """
      12
          de.renew.gui.CPNDrawing 4
              de.renew.fa.figures.FAStateFigure "attributes" "attributes" 2 "FigureWithID" "Int" 1 "FillColor" "Color" 255 255 255 255 10 20 40 40 NULL
                  de.renew.fa.figures.StartDecoration  "de.renew.fa.figures.StartDecoration"
              de.renew.fa.figures.FAStateFigure "attributes" "attributes" 2 "FigureWithID" "Int" 2 "FillColor" "Color" 255 255 255 255 60 20 40 40 NULL
                  de.renew.fa.figures.EndDecoration  "de.renew.fa.figures.EndDecoration"
              de.renew.fa.figures.FAStateFigure "attributes" "attributes" 2 "FigureWithID" "Int" 3 "FillColor" "Color" 255 255 255 255 110 20 40 40 NULL
                  de.renew.fa.figures.StartEndDecoration  "de.renew.fa.figures.StartEndDecoration"
              de.renew.fa.figures.FAStateFigure "attributes" "attributes" 2 "FigureWithID" "Int" 4 "FillColor" "Color" 255 255 255 255 160 20 40 40 NULL
                  de.renew.fa.figures.NullDecoration  "de.renew.fa.figures.NullDecoration"
              NULL
      """

      assert {:ok, imported} = RenewCollab.Import.DocumentImport.import("fa-states.rnw", rnw)

      decorations =
        imported.layers
        |> Enum.map(fn layer ->
          {layer["box"]["position_x"],
           get_in(layer, ["box", "symbol_shape_attributes", "fa_decoration"])}
        end)
        |> Map.new()

      assert decorations[10] == "start"
      assert decorations[60] == "end"
      assert decorations[110] == "start_end"
      assert decorations[160] == nil

      target_doc = test_document("Import FA state decorations")

      assert {:ok, _} =
               %InsertTransientDocument{
                 target_document_id: target_doc.id,
                 converted_document: imported,
                 position: {0, 0}
               }
               |> DocumentCommander.run_document_command_sync(false)

      stored_decorations =
        from(l in Layer,
          join: b in assoc(l, :box),
          where: l.document_id == ^target_doc.id,
          where: l.semantic_tag == "de.renew.fa.figures.FAStateFigure",
          select: {b.position_x, b.symbol_shape_attributes}
        )
        |> Repo.all()
        |> Map.new(fn {position_x, attributes} ->
          {round(position_x), attributes && Map.get(attributes, "fa_decoration")}
        end)

      assert stored_decorations[10] == "start"
      assert stored_decorations[60] == "end"
      assert stored_decorations[110] == "start_end"
      assert stored_decorations[160] == nil
    end

    test "ignores arc connector owners that are not visible drawing figures" do
      RenewCollab.SymbolFixtures.shape_fixture()
      RenewCollab.SocketFixtures.interface_fixture()

      target_doc = test_document("Import arc connector owners")

      rnw = """
      12
          de.renew.gui.CPNDrawing 2
              de.renew.gui.ArcConnection "attributes" "attributes" 1 "FigureWithID" "Int" 2 2 165 120 366 133 NULL
                  CH.ifa.draw.figures.ArrowTip 0.4 8.0 8.0 1  "CH.ifa.draw.figures.ArrowTip"
                  CH.ifa.draw.figures.ChopEllipseConnector
                      de.renew.gui.PlaceFigure "attributes" "attributes" 1 "FigureWithID" "Int" 1 65 76 101 83 NULL
                  CH.ifa.draw.standard.ChopBoxConnector
                      de.renew.gui.TransitionFigure "attributes" "attributes" 1 "FigureWithID" "Int" 3 366 126 24 16 NULL    REF 6 NULL
      """

      assert {:ok, imported} = RenewCollab.Import.DocumentImport.import("arctest.rnw", rnw)

      assert imported.layers |> Enum.map(& &1["semantic_tag"]) |> Enum.sort() == [
               "de.renew.gui.ArcConnection",
               "de.renew.gui.TransitionFigure"
             ]

      assert length(imported.bonds) == 1

      assert {:ok, %{inserted_layer_ids: inserted_layer_ids}} =
               %InsertTransientDocument{
                 target_document_id: target_doc.id,
                 converted_document: imported,
                 position: {0, 0}
               }
               |> DocumentCommander.run_document_command_sync(false)

      assert length(inserted_layer_ids) == 2

      imported_tags =
        from(l in Layer,
          where: l.document_id == ^target_doc.id,
          select: l.semantic_tag
        )
        |> Repo.all()
        |> Enum.sort()

      assert imported_tags == [
               "de.renew.gui.ArcConnection",
               "de.renew.gui.TransitionFigure"
             ]

      assert from(b in Bond,
               join: e in assoc(b, :element_edge),
               join: l in assoc(e, :layer),
               where: l.document_id == ^target_doc.id,
               select: count(b.id)
             )
             |> Repo.one() == 1
    end
  end

  describe "insert_layer_clipboard" do
    test "normalizes sibling z-indices after paste" do
      document = test_document("Paste z-index")
      test_layer(document, 1)

      lower_layer_id = Ecto.UUID.generate()
      upper_layer_id = Ecto.UUID.generate()

      clipboard = %{
        "format" => "renewex/layers",
        "version" => 1,
        "layers" => [
          %{"id" => lower_layer_id, "z_index" => 1, "hidden" => false},
          %{"id" => upper_layer_id, "z_index" => 2, "hidden" => false}
        ],
        "hierarchy" => [
          %{"ancestor_id" => lower_layer_id, "descendant_id" => lower_layer_id, "depth" => 0},
          %{"ancestor_id" => upper_layer_id, "descendant_id" => upper_layer_id, "depth" => 0}
        ],
        "hyperlinks" => [],
        "bonds" => [],
        "root_layer_ids" => [lower_layer_id, upper_layer_id],
        "origin" => %{"x" => 0, "y" => 0}
      }

      {:ok, %{inserted_layer_ids: inserted_layer_ids}} =
        %{
          document_id: document.id,
          clipboard: clipboard,
          position: {0, 0}
        }
        |> InsertLayerClipboard.new()
        |> DocumentCommander.run_document_command_sync(false)

      z_indexes = top_level_layer_z_indexes(document)

      assert length(inserted_layer_ids) == 2
      assert z_indexes == [1, 2, 3]
      assert Enum.uniq(z_indexes) == z_indexes
    end
  end

  describe "create_parent_layer" do
    test "wraps multiple sibling layers in one parent without reversing them" do
      document = test_document("Wrap multiple layers")
      bottom = test_layer(document, 1)
      middle = test_layer(document, 2)
      top = test_layer(document, 3)

      Enum.each([bottom, middle, top], &self_layer(document, &1))

      {:ok, %{layer: group}} =
        %{
          document_id: document.id,
          layer_ids: [bottom.id, top.id],
          attrs: %{"semantic_tag" => "CH.ifa.draw.figures.GroupFigure"}
        }
        |> CreateParentLayer.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert direct_child_ids(group) == [bottom.id, top.id]
      assert direct_parent_id(middle) == nil
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
        %{document_id: document_id, layer_ids: [source_layer_id], dx: 100.0, dy: 0.0}
        |> MoveLayerRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      text = from(t in Text, where: t.layer_id == ^edge_text_layer_id) |> Repo.one!()

      assert text.position_x > 100.0
      assert text.position_x < 200.0
    end
  end

  describe "reorder_layers_relative" do
    test "moves multiple sibling layers frontwards without reversing them" do
      document = test_document("Reorder frontwards")
      bottom = test_layer(document, 1)
      middle = test_layer(document, 2)
      top = test_layer(document, 3)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [bottom.id, middle.id],
          relative_direction: {:sibling, :next},
          target: {:above, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [top.id, bottom.id, middle.id]
    end

    test "moves multiple sibling layers backwards without reversing them" do
      document = test_document("Reorder backwards")
      bottom = test_layer(document, 1)
      middle = test_layer(document, 2)
      top = test_layer(document, 3)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [middle.id, top.id],
          relative_direction: {:sibling, :prev},
          target: {:below, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [middle.id, top.id, bottom.id]
    end

    test "keeps a frontmost multi-selection stable when moving frontwards" do
      document = test_document("Reorder frontmost frontwards")
      bottom = test_layer(document, 1)
      middle = test_layer(document, 2)
      top = test_layer(document, 3)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [middle.id, top.id],
          relative_direction: {:sibling, :next},
          target: {:above, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [bottom.id, middle.id, top.id]
    end

    test "keeps a backmost multi-selection stable when moving backwards" do
      document = test_document("Reorder backmost backwards")
      bottom = test_layer(document, 1)
      middle = test_layer(document, 2)
      top = test_layer(document, 3)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [bottom.id, middle.id],
          relative_direction: {:sibling, :prev},
          target: {:below, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [bottom.id, middle.id, top.id]
    end

    test "moves multiple sibling layers to front without reversing them" do
      document = test_document("Reorder to front")
      bottom = test_layer(document, 1)
      lower_middle = test_layer(document, 2)
      upper_middle = test_layer(document, 3)
      top = test_layer(document, 4)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [bottom.id, upper_middle.id],
          relative_direction: {:sibling, :last},
          target: {:above, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [
               lower_middle.id,
               top.id,
               bottom.id,
               upper_middle.id
             ]
    end

    test "keeps a frontmost multi-selection stable when moving to front" do
      document = test_document("Reorder frontmost to front")
      bottom = test_layer(document, 1)
      middle = test_layer(document, 2)
      top = test_layer(document, 3)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [middle.id, top.id],
          relative_direction: {:sibling, :last},
          target: {:above, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [bottom.id, middle.id, top.id]
    end

    test "moves multiple sibling layers to back without reversing them" do
      document = test_document("Reorder to back")
      bottom = test_layer(document, 1)
      lower_middle = test_layer(document, 2)
      upper_middle = test_layer(document, 3)
      top = test_layer(document, 4)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [lower_middle.id, top.id],
          relative_direction: {:sibling, :first},
          target: {:below, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [
               lower_middle.id,
               top.id,
               bottom.id,
               upper_middle.id
             ]
    end

    test "keeps a backmost multi-selection stable when moving to back" do
      document = test_document("Reorder backmost to back")
      bottom = test_layer(document, 1)
      middle = test_layer(document, 2)
      top = test_layer(document, 3)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [bottom.id, middle.id],
          relative_direction: {:sibling, :first},
          target: {:below, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [bottom.id, middle.id, top.id]
    end

    test "moves multiple child layers below their parent without reversing them" do
      document = test_document("Reorder below parent")
      parent = test_layer(document, 1)
      lower_child = test_layer(document, 1)
      upper_child = test_layer(document, 2)
      parent_layers(document, parent, [lower_child, upper_child])

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [lower_child.id, upper_child.id],
          relative_direction: :parent,
          target: {:below, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [lower_child.id, upper_child.id, parent.id]
      assert direct_parent_id(lower_child) == nil
      assert direct_parent_id(upper_child) == nil
    end

    test "moves multiple child layers above their parent without reversing them" do
      document = test_document("Reorder above parent")
      parent = test_layer(document, 1)
      lower_child = test_layer(document, 1)
      upper_child = test_layer(document, 2)
      parent_layers(document, parent, [lower_child, upper_child])

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [lower_child.id, upper_child.id],
          relative_direction: :parent,
          target: {:above, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [parent.id, lower_child.id, upper_child.id]
      assert direct_parent_id(lower_child) == nil
      assert direct_parent_id(upper_child) == nil
    end

    test "indents multiple sibling layers into the previous sibling without reversing them" do
      document = test_document("Reorder indent")
      first = test_layer(document, 1)
      parent = test_layer(document, 2)
      lower_child = test_layer(document, 3)
      upper_child = test_layer(document, 4)
      self_layer(document, parent)
      self_layer(document, lower_child)
      self_layer(document, upper_child)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [lower_child.id, upper_child.id],
          relative_direction: {:sibling, :prev},
          target: {:above, :inside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert top_level_layer_ids(document) == [first.id, parent.id]
      assert direct_parent_id(lower_child) == parent.id
      assert direct_parent_id(upper_child) == parent.id
      assert direct_child_ids(parent) == [lower_child.id, upper_child.id]
    end

    test "ignores selected children when their parent is selected too" do
      document = test_document("Reorder parent child")
      parent = test_layer(document, 1)
      child = test_layer(document, 2)
      parent_layer(document, parent, child)

      {:ok, _} =
        %{
          document_id: document.id,
          layer_ids: [parent.id, child.id],
          relative_direction: :parent,
          target: {:below, :outside}
        }
        |> ReorderLayersRelative.new()
        |> DocumentCommander.run_document_command_sync(false)

      assert direct_parent_id(child) == parent.id
    end
  end
end
