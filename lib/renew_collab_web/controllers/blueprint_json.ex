defmodule RenewCollabWeb.BlueprintJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{documents: documents}) do
    %{
      blueprints:
        documents
        |> Enum.map(fn doc ->
          %{name: doc.name, id: doc.id}
        end)
    }
  end

  def primitives(%{groups: groups}) do
    %{
      groups:
        groups
        |> Enum.map(fn g ->
          %{
            name: g.name,
            items:
              g.primitives
              |> Enum.map(fn p ->
                %{
                  name: p.name,
                  data: p.data,
                  icon: p.icon
                }
              end)
          }
        end)
    }
  end
end
