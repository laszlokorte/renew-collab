defmodule RenewCollab.Versioning.Snapshotter do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.LayerParenthood
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Hyperlink
  alias RenewCollab.Connection.Bond
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Element.Text
  alias RenewCollab.Element.Box
  alias RenewCollab.Element.Interface
  alias RenewCollab.Element.Edge
  alias RenewCollab.Style.EdgeStyle
  alias RenewCollab.Style.TextStyle
  alias RenewCollab.Style.LayerStyle

  def queries() do
    [
      {:layers,
       {Layer,
        fn document_id ->
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
        end}},
      {:layer_styles,
       {LayerStyle,
        fn document_id ->
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
        end}},
      {:boxes,
       {Box,
        fn document_id ->
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
        end}},
      {:edges,
       {Edge,
        fn document_id ->
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
        end}},
      {:waypoints,
       {Waypoint,
        fn document_id ->
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
        end}},
      {:interfaces,
       {Interface,
        fn document_id ->
          from(l in Layer,
            where: l.document_id == ^document_id,
            join: i in assoc(l, :interface),
            select: %{
              id: i.id,
              layer_id: i.layer_id,
              socket_schema_id: i.socket_schema_id,
              inserted_at: i.inserted_at,
              updated_at: i.updated_at
            }
          )
        end}},
      {:textes,
       {Text,
        fn document_id ->
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
        end}},
      {:hyperlinks,
       {Hyperlink,
        fn document_id ->
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
        end}},
      {:bonds,
       {Bond,
        fn document_id ->
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
        end}},
      {:edge_styles,
       {EdgeStyle,
        fn document_id ->
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
        end}},
      {:text_styles,
       {TextStyle,
        fn document_id ->
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
        end}},
      {:parenthoods,
       {LayerParenthood,
        fn document_id ->
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
        end}}
    ]
  end
end
