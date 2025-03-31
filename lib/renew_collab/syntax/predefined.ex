defmodule RenewCollab.Syntax.Predefined do
  def all() do
    [
      %{
        "id" => "fbf7adeb-9f28-49b3-a475-0bf37dd6d376",
        "name" => "Reference Net",
        "edge_whitelists" => [
          %{
            "id" => "f9d94642-82d1-4d9b-8b87-937a3782be15",
            "source_semantic_tag" => "de.renew.gui.TransitionFigure",
            "target_semantic_tag" => "de.renew.gui.PlaceFigure",
            "edge_semantic_tag" => "de.renew.gui.ArcConnection"
          },
          %{
            "id" => "67344da3-9462-4b32-b30e-808b3c467304",
            "source_semantic_tag" => "de.renew.gui.PlaceFigure",
            "target_semantic_tag" => "de.renew.gui.TransitionFigure",
            "edge_semantic_tag" => "de.renew.gui.ArcConnection"
          }
        ],
        "edge_auto_targets" => [
          %{
            "id" => "0e290cd2-219b-4f9e-b6db-0eb80119f7c2",
            "source_semantic_tag" => "de.renew.gui.TransitionFigure",
            "source_socket_id" => "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD",
            "target_shape_id" => "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
            "target_socket_id" => "9BE09A98-DECF-4D38-8A06-5381B51D7538",
            "target_semantic_tag" => "de.renew.gui.PlaceFigure",
            "edge_semantic_tag" => "de.renew.gui.ArcConnection",
            "edge_source_tip_id" => nil,
            "edge_target_tip_id" => "84DC6617-D555-4BAB-BA33-04A5FA442F00"
          },
          %{
            "id" => "56893c50-cb7b-4a12-9517-ea373aa61b03",
            "source_semantic_tag" => "de.renew.gui.PlaceFigure",
            "source_socket_id" => "9BE09A98-DECF-4D38-8A06-5381B51D7538",
            "target_shape_id" => "2DD432FE-CC8A-4259-8A84-63F75AF0ECE0",
            "target_socket_id" => "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD",
            "target_semantic_tag" => "de.renew.gui.TransitionFigure",
            "edge_semantic_tag" => "de.renew.gui.ArcConnection",
            "edge_source_tip_id" => nil,
            "edge_target_tip_id" => "84DC6617-D555-4BAB-BA33-04A5FA442F00"
          }
        ]
      }
    ]
  end
end
