defmodule RenewCollab.Syntax.Predefined do
  @place "de.renew.gui.PlaceFigure"
  @transition "de.renew.gui.TransitionFigure"
  @virtual_place "de.renew.gui.VirtualPlaceFigure"
  @virtual_transition "de.renew.gui.VirtualTransitionFigure"
  @arc "de.renew.gui.ArcConnection"
  @double_arc "de.renew.gui.DoubleArcConnection"
  @inhibitor_arc "de.renew.gui.InhibitorConnection"
  @clear_arc "de.renew.gui.HollowDoubleArcConnection"

  def all() do
    [
      %{
        :id => "fbf7adeb-9f28-49b3-a475-0bf37dd6d376",
        :name => "Reference Net",
        :default => %{
          :id => "b7ad6d3a-d486-4165-a687-6a7e685939d8"
        },
        :edge_whitelists => reference_net_edge_whitelists(),
        :edge_auto_targets => [
          %{
            :id => "0e290cd2-219b-4f9e-b6db-0eb80119f7c2",
            :source_semantic_tag => "de.renew.gui.TransitionFigure",
            :source_socket_id => "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD",
            :target_shape_id => "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
            :target_socket_id => "9BE09A98-DECF-4D38-8A06-5381B51D7538",
            :target_semantic_tag => "de.renew.gui.PlaceFigure",
            :edge_semantic_tag => "de.renew.gui.ArcConnection",
            :edge_source_tip_id => nil,
            :edge_target_tip_id => "84DC6617-D555-4BAB-BA33-04A5FA442F00"
          },
          %{
            :id => "4bc9b04f-bae1-431c-aa55-1766a98a2c8f",
            :source_semantic_tag => "de.renew.gui.VirtualTransitionFigure",
            :source_socket_id => "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD",
            :target_shape_id => "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
            :target_socket_id => "9BE09A98-DECF-4D38-8A06-5381B51D7538",
            :target_semantic_tag => "de.renew.gui.PlaceFigure",
            :edge_semantic_tag => "de.renew.gui.ArcConnection",
            :edge_source_tip_id => nil,
            :edge_target_tip_id => "84DC6617-D555-4BAB-BA33-04A5FA442F00"
          },
          %{
            :id => "56893c50-cb7b-4a12-9517-ea373aa61b03",
            :source_semantic_tag => "de.renew.gui.PlaceFigure",
            :source_socket_id => "9BE09A98-DECF-4D38-8A06-5381B51D7538",
            :target_shape_id => "2DD432FE-CC8A-4259-8A84-63F75AF0ECE0",
            :target_socket_id => "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD",
            :target_semantic_tag => "de.renew.gui.TransitionFigure",
            :edge_semantic_tag => "de.renew.gui.ArcConnection",
            :edge_source_tip_id => nil,
            :edge_target_tip_id => "84DC6617-D555-4BAB-BA33-04A5FA442F00"
          },
          %{
            :id => "0e3e8d22-e717-42c7-a82e-e64ce7f8d340",
            :source_semantic_tag => "de.renew.gui.VirtualPlaceFigure",
            :source_socket_id => "9BE09A98-DECF-4D38-8A06-5381B51D7538",
            :target_shape_id => "2DD432FE-CC8A-4259-8A84-63F75AF0ECE0",
            :target_socket_id => "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD",
            :target_semantic_tag => "de.renew.gui.TransitionFigure",
            :edge_semantic_tag => "de.renew.gui.ArcConnection",
            :edge_source_tip_id => nil,
            :edge_target_tip_id => "84DC6617-D555-4BAB-BA33-04A5FA442F00"
          }
        ]
      },
      %{
        :id => "efdd30ab-1c36-41f0-8aff-58657bfe2e02",
        :name => "FSM",
        :edge_whitelists => [
          %{
            :id => "4cbb23c4-2ec7-467d-978d-2d6db73769d7",
            :source_semantic_tag => "de.renew.fa.figures.FAStateFigure",
            :target_semantic_tag => "de.renew.fa.figures.FAStateFigure",
            :edge_semantic_tag => "de.renew.fa.figures.FAArcConnection"
          }
        ],
        :edge_auto_targets => [
          %{
            :id => "da932bd1-6c2a-41b0-9b8a-ab33f36cee9c",
            :source_semantic_tag => "de.renew.fa.figures.FAStateFigure",
            :source_socket_id => "9BE09A98-DECF-4D38-8A06-5381B51D7538",
            :target_shape_id => "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
            :target_socket_id => "9BE09A98-DECF-4D38-8A06-5381B51D7538",
            :target_semantic_tag => "de.renew.fa.figures.FAStateFigure",
            :edge_semantic_tag => "de.renew.fa.figures.FAArcConnection",
            :edge_source_tip_id => nil,
            :edge_target_tip_id => "84DC6617-D555-4BAB-BA33-04A5FA442F00",
            :style => %{
              background_color: "white",
              border_color: "black",
              border_width: "2"
            }
          }
        ]
      }
    ]
  end

  defp reference_net_edge_whitelists do
    ordinary_rules = [
      rule("f9d94642-82d1-4d9b-8b87-937a3782be15", @transition, @place, @arc),
      rule("32f73d56-39af-44b4-85a2-15e12e2ee948", @transition, @virtual_place, @arc),
      rule("12bbdfb0-3a23-4d4c-b8de-cc37b11a53ef", @virtual_transition, @place, @arc),
      rule("9035b4bf-d328-4647-a192-f2d474da10cb", @virtual_transition, @virtual_place, @arc),
      rule("67344da3-9462-4b32-b30e-808b3c467304", @place, @transition, @arc),
      rule("70a6e172-9281-4461-8d7d-4478fb7c7bea", @place, @virtual_transition, @arc),
      rule("5b763f08-6165-4d88-a8b4-3af6f4ce2fc0", @virtual_place, @transition, @arc),
      rule("8d901c60-73ff-43b9-a991-c765ea3253b6", @virtual_place, @virtual_transition, @arc)
    ]

    net_pairs = [
      {@transition, @place},
      {@transition, @virtual_place},
      {@virtual_transition, @place},
      {@virtual_transition, @virtual_place},
      {@place, @transition},
      {@place, @virtual_transition},
      {@virtual_place, @transition},
      {@virtual_place, @virtual_transition}
    ]

    ordinary_rules ++
      typed_rules("20000000-0000-0000-0000-00000000000", net_pairs, @double_arc) ++
      typed_rules("30000000-0000-0000-0000-00000000000", net_pairs, @inhibitor_arc) ++
      [rule("40000000-0000-0000-0000-000000000001", @place, @transition, @clear_arc)]
  end

  defp typed_rules(prefix, pairs, edge_semantic_tag) do
    pairs
    |> Enum.with_index(1)
    |> Enum.map(fn {{source, target}, index} ->
      rule("#{prefix}#{index}", source, target, edge_semantic_tag)
    end)
  end

  defp rule(id, source_semantic_tag, target_semantic_tag, edge_semantic_tag) do
    %{
      :id => id,
      :source_semantic_tag => source_semantic_tag,
      :target_semantic_tag => target_semantic_tag,
      :edge_semantic_tag => edge_semantic_tag
    }
  end
end
