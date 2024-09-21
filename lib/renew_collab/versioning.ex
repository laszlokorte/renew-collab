defmodule RenewCollab.Versioning do
  import Ecto.Query, warn: false

  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Repo
  alias RenewCollab.Renew
  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Renew
  alias RenewCollab.Element.Text
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Edge
  alias RenewCollab.Style.EdgeStyle
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Style.LayerStyle

  def document_versions(document_id) do
    from(s in Snapshot,
      where: s.document_id == ^document_id,
      select: %{id: s.id, inserted_at: s.inserted_at},
      order_by: [desc: s.inserted_at]
    )
    |> Repo.all()
  end

  def create_snapshot(document_id) do
    edge_styles =
      from(l in Layer,
        where: l.document_id == ^document_id,
        join: e in assoc(l, :edge),
        join: s in assoc(e, :style),
        select: %{
          id: s.id,
          stroke_width: s.stroke_width,
          stroke_color: s.stroke_color,
          stroke_join: s.stroke_join,
          stroke_cap: s.stroke_cap,
          stroke_dash_array: s.stroke_dash_array,
          source_tip: s.source_tip,
          target_tip: s.target_tip,
          smoothness: s.smoothness,
          source_tip_symbol_shape_id: s.source_tip_symbol_shape_id,
          target_tip_symbol_shape_id: s.target_tip_symbol_shape_id,
          edge_id: s.edge_id,
          inserted_at: s.inserted_at,
          updated_at: s.updated_at
        }
      )
      |> Repo.all()

    text_styles =
      from(l in Layer,
        where: l.document_id == ^document_id,
        join: t in assoc(l, :text),
        join: s in assoc(t, :style),
        select: %{
          id: s.id,
          italic: s.italic,
          underline: s.underline,
          rich: s.rich,
          blank_lines: s.blank_lines,
          alignment: s.alignment,
          font_size: s.font_size,
          font_family: s.font_family,
          bold: s.bold,
          text_color: s.text_color,
          text_id: s.text_id,
          inserted_at: s.inserted_at,
          updated_at: s.updated_at
        }
      )
      |> Repo.all()

    layer_styles =
      from(l in Layer,
        where: l.document_id == ^document_id,
        join: s in assoc(l, :style),
        select: %{
          id: s.id,
          opacity: s.opacity,
          background_color: s.background_color,
          border_color: s.border_color,
          border_width: s.border_width,
          border_dash_array: s.border_dash_array,
          layer_id: s.layer_id,
          inserted_at: s.inserted_at,
          updated_at: s.updated_at
        }
      )
      |> Repo.all()

    waypoints =
      from(l in Layer,
        where: l.document_id == ^document_id,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        select: %{
          id: w.id,
          sort: w.sort,
          position_x: w.position_x,
          position_y: w.position_y,
          edge_id: w.edge_id,
          inserted_at: w.inserted_at,
          updated_at: w.updated_at
        }
      )
      |> Repo.all()

    edges =
      from(l in Layer,
        where: l.document_id == ^document_id,
        join: e in assoc(l, :edge),
        select: %{
          id: e.id,
          layer_id: e.layer_id,
          source_x: e.source_x,
          source_y: e.source_y,
          target_x: e.target_x,
          target_y: e.target_y,
          cyclic: e.cyclic,
          inserted_at: e.inserted_at,
          updated_at: e.updated_at
        }
      )
      |> Repo.all()

    boxes =
      from(l in Layer,
        where: l.document_id == ^document_id,
        join: b in assoc(l, :box),
        select: %{
          id: b.id,
          layer_id: b.layer_id,
          position_x: b.position_x,
          position_y: b.position_y,
          width: b.width,
          height: b.height,
          symbol_shape_attributes: b.symbol_shape_attributes,
          symbol_shape_id: b.symbol_shape_id,
          inserted_at: b.inserted_at,
          updated_at: b.updated_at
        }
      )
      |> Repo.all()

    textes =
      from(l in Layer,
        where: l.document_id == ^document_id,
        join: t in assoc(l, :text),
        select: %{
          id: t.id,
          layer_id: t.layer_id,
          position_x: t.position_x,
          position_y: t.position_y,
          body: t.body,
          inserted_at: t.inserted_at,
          updated_at: t.updated_at
        }
      )
      |> Repo.all()

    layers =
      from(l in Layer,
        where: l.document_id == ^document_id,
        select: %{
          id: l.id,
          z_index: l.z_index,
          semantic_tag: l.semantic_tag,
          hidden: l.hidden,
          document_id: l.document_id,
          inserted_at: l.inserted_at,
          updated_at: l.updated_at
        }
      )
      |> Repo.all()

    parenthoods =
      from(p in LayerParenthood,
        where: p.document_id == ^document_id,
        select: %{
          id: p.id,
          depth: p.depth,
          document_id: p.document_id,
          ancestor_id: p.ancestor_id,
          descendant_id: p.descendant_id
        }
      )
      |> Repo.all()

    hyperlinks =
      from(h in Hyperlink,
        join: s in assoc(h, :source_layer),
        join: t in assoc(h, :target_layer),
        where: s.document_id == ^document_id and t.document_id == ^document_id,
        select: %{
          id: h.id,
          source_layer_id: h.source_layer_id,
          target_layer_id: h.target_layer_id,
          inserted_at: h.inserted_at,
          updated_at: h.updated_at
        }
      )
      |> Repo.all()

    bonds =
      from(b in Bond,
        join: e in assoc(b, :element_edge),
        join: l in assoc(e, :layer),
        where: l.document_id == ^document_id,
        select: %{
          id: b.id,
          element_edge_id: b.element_edge_id,
          layer_id: b.layer_id,
          socket_id: b.socket_id,
          kind: b.kind,
          inserted_at: b.inserted_at,
          updated_at: b.updated_at
        }
      )
      |> Repo.all()

    %Snapshot{document_id: document_id}
    |> Snapshot.changeset(%{
      content:
        ensure_map_deep(%{
          waypoints: waypoints,
          edges: edges,
          boxes: boxes,
          textes: textes,
          layers: layers,
          parenthoods: parenthoods,
          hyperlinks: hyperlinks,
          bonds: bonds,
          edge_styles: edge_styles,
          text_styles: text_styles,
          layer_styles: layer_styles
        })
        |> dbg()
    })
    |> Repo.insert()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end

  def restore_snapshot(document_id, snapshot_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :snapshot,
      from(s in Snapshot, where: s.id == ^snapshot_id)
    )
    |> Ecto.Multi.run(
      :snapshot_content,
      fn _, %{snapshot: %Snapshot{content: content}} ->
        {:ok, content}
      end
    )
    |> Ecto.Multi.delete_all(
      :delete_all_layers,
      fn
        %{} ->
          from(l in Layer,
            where: l.document_id == ^document_id
          )
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_layers,
      Layer,
      fn
        %{snapshot_content: %{"layers" => layers}} ->
          layers
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_textes,
      Text,
      fn
        %{snapshot_content: %{"textes" => textes}} ->
          textes
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_boxes,
      Box,
      fn
        %{snapshot_content: %{"boxes" => boxes}} ->
          boxes
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_edges,
      Edge,
      fn
        %{snapshot_content: %{"edges" => edges}} ->
          edges
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_waypoints,
      Waypoint,
      fn
        %{snapshot_content: %{"waypoints" => waypoints}} ->
          waypoints
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_parenthoods,
      LayerParenthood,
      fn
        %{snapshot_content: %{"parenthoods" => parenthoods}} ->
          parenthoods
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_hyperlinks,
      Hyperlink,
      fn
        %{snapshot_content: %{"hyperlinks" => hyperlinks}} ->
          hyperlinks
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_bonds,
      Bond,
      fn
        %{snapshot_content: %{"bonds" => bonds}} ->
          bonds
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_edge_styles,
      EdgeStyle,
      fn
        %{snapshot_content: %{"edge_styles" => edge_styles}} ->
          edge_styles
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_text_styles,
      TextStyle,
      fn
        %{snapshot_content: %{"text_styles" => text_styles}} ->
          text_styles
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Ecto.Multi.insert_all(
      :restore_layer_styles,
      LayerStyle,
      fn
        %{snapshot_content: %{"layer_styles" => layer_styles}} ->
          layer_styles
          |> Enum.map(fn row ->
            row
            |> Enum.map(&{String.to_atom(elem(&1, 0)), elem(&1, 1)})
            |> Enum.map(&restore_json/1)
            |> Map.new()
          end)
      end
    )
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "redux_document:#{document_id}",
          {:document_changed, document_id}
        )
    end
  end

  defp ensure_map_deep(data) do
    ensure_map(data)
    |> case do
      l when is_list(l) -> Enum.map(l, &ensure_map_deep/1)
      s when is_struct(s) -> s
      m when is_map(m) -> Enum.map(m, fn {k, v} -> {k, ensure_map_deep(v)} end) |> Map.new()
      other -> other
    end
  end

  defp ensure_map(%Ecto.Association.NotLoaded{}), do: nil
  defp ensure_map(%DateTime{} = struct), do: struct

  defp ensure_map(%{__struct__: _} = struct),
    do: struct |> Map.from_struct() |> Map.delete(:__meta__)

  defp ensure_map(data), do: data

  defp restore_json({:inserted_at, data}) do
    {:ok, datetime, _} = DateTime.from_iso8601(data)

    {:inserted_at, datetime}
  end

  defp restore_json({:updated_at, data}) do
    {:ok, datetime, _} = DateTime.from_iso8601(data)

    {:updated_at, datetime}
  end

  defp restore_json({:kind, "source"}) do
    {:kind, :source}
  end

  defp restore_json({:kind, "target"}) do
    {:kind, :target}
  end

  defp restore_json({:smoothness, "autobezier"}) do
    {:smoothness, :autobezier}
  end

  defp restore_json({:smoothness, "linear"}) do
    {:smoothness, :linear}
  end

  defp restore_json({:alignment, "left"}) do
    {:alignment, :left}
  end

  defp restore_json({:alignment, "center"}) do
    {:alignment, :center}
  end

  defp restore_json({:alignment, "right"}) do
    {:alignment, :right}
  end

  defp restore_json(other), do: other
end
