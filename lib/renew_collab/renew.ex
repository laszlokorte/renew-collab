defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.LayerStyle
  alias RenewCollab.Style.EdgeStyle
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Hierarchy.LayerParenthood

  def reset do
    Repo.delete_all(Document)
  end

  def list_documents do
    Repo.all(Document, order_by: [asc: :inserted_at])
  end

  def get_document!(id), do: Repo.get!(Document, id)

  def get_document_with_elements!(id),
    do:
      Repo.get!(Document, id)
      |> Repo.preload(
        layers:
          from(e in Layer,
            order_by: [asc: :z_index],
            preload: [
              direct_parent: [],
              box: [
                symbol_shape: []
              ],
              text: [style: []],
              edge: [
                waypoints: ^from(w in Waypoint, order_by: [asc: :sort]),
                style: []
              ],
              style: [],
              sockets: []
            ]
          )
      )

  def create_document(attrs \\ %{}, parenthoods \\ []) do
    with {:ok, transaction} <-
           Ecto.Multi.new()
           |> Ecto.Multi.insert(
             :insert_document,
             %Document{} |> Document.changeset(attrs)
           )
           |> Ecto.Multi.insert_all(
             :insert_parenthoods,
             LayerParenthood,
             fn %{insert_document: new_document} ->
               Enum.map(
                 parenthoods,
                 fn {ancestor_id, descendant_id, depth} ->
                   %{
                     depth: depth,
                     ancestor_id: ancestor_id,
                     descendant_id: descendant_id,
                     document_id: new_document.id
                   }
                 end
               )
             end,
             on_conflict: {:replace, [:depth, :ancestor_id, :descendant_id]}
           )
           |> Repo.transaction() do
      {:ok, Map.get(transaction, :insert_document)}
    else
      e -> dbg(e)
    end
  end

  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  def create_element(%Document{} = document, attrs \\ %{}) do
    {:ok, %{insert_layer: layer}} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :insert_layer,
        Layer.changeset(%Layer{document_id: document.id}, attrs)
      )
      |> Ecto.Multi.insert(
        :insert_parenthood,
        fn %{insert_layer: new_layer} ->
          LayerParenthood.changeset(%LayerParenthood{}, %{
            depth: 0,
            document_id: new_layer.document_id,
            ancestor_id: new_layer.id,
            descendant_id: new_layer.id
          })
        end
      )
      |> Repo.transaction()

    {:ok, layer}
  end

  def get_element!(document, id) do
    Repo.get_by(Layer, id: id, document: document)
    |> Repo.preload(
      box: [
        symbol_shape: []
      ],
      text: [style: []],
      edge: [
        waypoints: from(w in Waypoint, order_by: [asc: :sort]),
        style: []
      ],
      style: [],
      sockets: []
    )
  end

  def toggle_visible(layer_id) do
    query =
      from(
        l in Layer,
        where: l.id == ^layer_id,
        update: [set: [hidden: not l.hidden]]
      )

    # Update the record
    Repo.update_all(query, [])
  end

  def layer_style_key("opacity"), do: :opacity
  def layer_style_key("background_color"), do: :background_color
  def layer_style_key("border_color"), do: :border_color
  def layer_style_key("border_width"), do: :border_width
  def layer_style_key("border_dash_array"), do: :border_dash_array

  def update_layer_style(document_id, layer_id, style_attr, color) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(:layer, from(l in Layer, where: l.id == ^layer_id))
    |> Ecto.Multi.insert(
      :style,
      fn %{layer: layer} ->
        Ecto.build_assoc(layer, :style)
        |> LayerStyle.changeset(%{style_attr => color})
      end,
      on_conflict: {:replace, [style_attr]}
    )
    |> Repo.transaction()
  end

  def layer_edge_style_key("stroke_width"), do: :stroke_width
  def layer_edge_style_key("stroke_color"), do: :stroke_color
  def layer_edge_style_key("stroke_join"), do: :stroke_join
  def layer_edge_style_key("stroke_cap"), do: :stroke_cap
  def layer_edge_style_key("stroke_dash_array"), do: :stroke_dash_array
  def layer_edge_style_key("smoothness"), do: :smoothness
  def layer_edge_style_key("source_tip_symbol_shape_id"), do: :source_tip_symbol_shape_id
  def layer_edge_style_key("target_tip_symbol_shape_id"), do: :target_tip_symbol_shape_id

  def update_layer_edge_style(document_id, layer_id, style_attr, color) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: e in assoc(l, :edge), where: l.id == ^layer_id, select: e)
    )
    |> Ecto.Multi.insert(
      :style,
      fn %{edge: edge} ->
        Ecto.build_assoc(edge, :style)
        |> EdgeStyle.changeset(%{style_attr => color})
      end,
      on_conflict: {:replace, [style_attr]}
    )
    |> Repo.transaction()
  end

  def layer_text_style_key("italic"), do: :italic
  def layer_text_style_key("underline"), do: :underline
  def layer_text_style_key("alignment"), do: :alignment
  def layer_text_style_key("font_size"), do: :font_size
  def layer_text_style_key("font_family"), do: :font_family
  def layer_text_style_key("bold"), do: :bold
  def layer_text_style_key("text_color"), do: :text_color

  def update_layer_text_style(document_id, layer_id, style_attr, color) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: e in assoc(l, :text), where: l.id == ^layer_id, select: e)
    )
    |> Ecto.Multi.insert(
      :style,
      fn %{text: text} ->
        Ecto.build_assoc(text, :style)
        |> TextStyle.changeset(%{style_attr => color})
      end,
      on_conflict: {:replace, [style_attr]}
    )
    |> Repo.transaction()
  end

  def update_layer_text_body(
        document_id,
        layer_id,
        new_body
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: t in assoc(l, :text), where: l.id == ^layer_id, select: t)
    )
    |> Ecto.Multi.update(
      :body,
      fn %{text: text} ->
        Ecto.Changeset.change(text, body: new_body)
      end
    )
    |> Repo.transaction()
  end

  def update_layer_box_size(
        document_id,
        layer_id,
        %{
          position_x: position_x,
          position_y: position_y,
          width: width,
          height: height
        }
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :box,
      from(l in Layer, join: b in assoc(l, :box), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{box: box} ->
        Ecto.Changeset.change(box, %{
          position_x: position_x,
          position_y: position_y,
          width: width,
          height: height
        })
      end
    )
    |> Repo.transaction()
  end

  def parse_layer_box_size(%{
        "position_x" => position_x,
        "position_y" => position_y,
        "width" => width,
        "height" => height
      }) do
    with {position_x, _} <- Float.parse(position_x),
         {position_y, _} <- Float.parse(position_y),
         {width, _} <- Float.parse(width),
         {height, _} <- Float.parse(height) do
      %{
        position_x: position_x,
        position_y: position_y,
        width: width,
        height: height
      }
    end
  end

  def update_layer_text_position(
        document_id,
        layer_id,
        %{
          position_x: position_x,
          position_y: position_y
        }
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :text,
      from(l in Layer, join: t in assoc(l, :text), where: l.id == ^layer_id, select: t)
    )
    |> Ecto.Multi.update(
      :size,
      fn %{text: text} ->
        Ecto.Changeset.change(text, %{
          position_x: position_x,
          position_y: position_y
        })
      end
    )
    |> Repo.transaction()
  end

  def parse_layer_text_position(%{
        "position_x" => position_x,
        "position_y" => position_y
      }) do
    with {position_x, _} <- Float.parse(position_x),
         {position_y, _} <- Float.parse(position_y) do
      %{
        position_x: position_x,
        position_y: position_y
      }
    end
  end

  def update_layer_z_index(
        document_id,
        layer_id,
        z_index
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :layer,
      from(l in Layer, where: l.id == ^layer_id, select: l)
    )
    |> Ecto.Multi.update(
      :z_index,
      fn %{layer: layer} ->
        Ecto.Changeset.change(layer, %{
          z_index: z_index
        })
      end
    )
    |> Repo.transaction()
  end

  def parse_layer_z_index(z_index) do
    with {z_index, _} <- Integer.parse(z_index) do
      z_index
    end
  end

  def update_layer_edge_position(
        document_id,
        layer_id,
        %{
          source_x: source_x,
          source_y: source_y,
          target_x: target_x,
          target_y: target_y
        }
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :edge,
      from(l in Layer, join: b in assoc(l, :edge), where: l.id == ^layer_id, select: b)
    )
    |> Ecto.Multi.update(
      :position,
      fn %{edge: edge} ->
        Ecto.Changeset.change(edge, %{
          source_x: source_x,
          source_y: source_y,
          target_x: target_x,
          target_y: target_y
        })
      end
    )
    |> Repo.transaction()
  end

  def parse_layer_edge_position(%{
        "source_x" => source_x,
        "source_y" => source_y,
        "target_x" => target_x,
        "target_y" => target_y
      }) do
    with {source_x, _} <- Float.parse(source_x),
         {source_y, _} <- Float.parse(source_y),
         {target_x, _} <- Float.parse(target_x),
         {target_y, _} <- Float.parse(target_y) do
      %{
        source_x: source_x,
        source_y: source_y,
        target_x: target_x,
        target_y: target_y
      }
    end
  end

  def update_layer_edge_waypoint_position(
        document_id,
        layer_id,
        waypoint_id,
        %{
          position_x: position_x,
          position_y: position_y
        }
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :waypoint,
      from(l in Layer,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        where: l.id == ^layer_id and w.id == ^waypoint_id,
        select: w
      )
    )
    |> Ecto.Multi.update(
      :size,
      fn %{waypoint: waypoint} ->
        Ecto.Changeset.change(waypoint, %{
          position_x: position_x,
          position_y: position_y
        })
      end
    )
    |> Repo.transaction()
  end

  def parse_layer_edge_waypoint_position(%{
        "position_x" => position_x,
        "position_y" => position_y
      }) do
    with {position_x, _} <- Float.parse(position_x),
         {position_y, _} <- Float.parse(position_y) do
      %{
        position_x: position_x,
        position_y: position_y
      }
    end
  end

  def delete_layer_edge_waypoint(
        document_id,
        layer_id,
        waypoint_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :waypoint,
      from(l in Layer,
        join: e in assoc(l, :edge),
        join: w in assoc(e, :waypoints),
        where: l.id == ^layer_id and w.id == ^waypoint_id,
        select: w
      )
    )
    |> Ecto.Multi.delete(
      :deletion,
      fn %{waypoint: waypoint} ->
        waypoint
      end
    )
    |> Repo.transaction()
  end

  def create_layer_edge_waypoint(
        document_id,
        layer_id,
        after_waypoint_id
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :edge,
      if is_nil(after_waypoint_id) do
        from(l in Layer,
          join: e in assoc(l, :edge),
          where: l.id == ^layer_id,
          select: {e, nil}
        )
      else
        from(l in Layer,
          join: e in assoc(l, :edge),
          left_join: w in assoc(e, :waypoints),
          on: w.id == ^after_waypoint_id,
          where: l.id == ^layer_id,
          select: {e, w}
        )
      end
    )
    |> Ecto.Multi.insert(
      :insert,
      fn
        %{edge: {edge, nil}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: 0,
            position_x: 0,
            position_y: 0,
            edge_id: edge.id
          })

        %{edge: {edge, waypoint}} ->
          %Waypoint{}
          |> Waypoint.changeset(%{
            sort: 0,
            position_x: 0,
            position_y: 0,
            edge_id: edge.id
          })
      end,
      on_conflict: {:replace, [:position_x, :position_y]}
    )
    |> Repo.transaction()
  end
end
