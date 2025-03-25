defmodule RenewCollabWeb.SemanticTagJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{semantic_tags: semantic_tags}) do
    %{
      semantic_tags: semantic_tags
    }
  end

  def rules(%{}) do
    %{
      "edgeWhitelist" => %{
        "de.renew.gui.TransitionFigure" => ["de.renew.gui.PlaceFigure"],
        "de.renew.gui.PlaceFigure" => ["de.renew.gui.TransitionFigure"]
      },
      "autoEdgeNode" => %{
        "de.renew.gui.TransitionFigure" => %{
          "target" => %{
            "shape_id" => "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
            "semantic_tag" => "de.renew.gui.PlaceFigure",
            "socket_schema_id" => "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC"
          },
          "edge" => %{
            "target" => %{
              "socket_id" => "9BE09A98-DECF-4D38-8A06-5381B51D7538"
            },
            "source" => %{"socket_id" => "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD"}
          }
        },
        "de.renew.gui.PlaceFigure" => %{
          "target" => %{
            "shape_id" => "2DD432FE-CC8A-4259-8A84-63F75AF0ECE0",
            "semantic_tag" => "de.renew.gui.TransitionFigure",
            "socket_schema_id" => "4FDF577B-DB81-462E-971E-FA842F0ABA1E"
          },
          "edge" => %{
            "target" => %{
              "socket_id" => "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD"
            },
            "source" => %{"socket_id" => "9BE09A98-DECF-4D38-8A06-5381B51D7538"}
          }
        }
      }
    }
  end
end
