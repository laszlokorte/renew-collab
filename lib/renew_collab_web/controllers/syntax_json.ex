defmodule RenewCollabWeb.SyntaxJSON do
  use RenewCollabWeb, :verified_routes

  def list(%{syntaxes: syntaxes}) do
    %{
      items:
        for s <- syntaxes do
          %{id: s.id, name: s.name, href: url(~p"/api/syntax/#{s.id}")}
        end
    }
  end

  def rules(%{syntax: syntax}) do
    %{
      "edgeWhitelist" =>
        syntax.edge_whitelists
        |> Enum.group_by(
          & &1.source_semantic_tag,
          & &1.target_semantic_tag
        ),
      "autoEdgeNode" =>
        syntax.edge_auto_targets
        |> Enum.map(fn t ->
          {t.source_semantic_tag,
           %{
             "target" => %{
               "shape_id" => t.target_shape_id,
               "semantic_tag" => t.target_semantic_tag,
               "socket_schema_id" => t.target_socket.socket_schema_id,
               "style" => t.style
             },
             "edge" => %{
               "target" => %{
                 "socket_id" => t.target_socket_id
               },
               "source" => %{"socket_id" => t.source_socket_id},
               "semantic_tag" => t.edge_semantic_tag
             }
           }}
        end)
        |> Map.new()
    }
  end
end
