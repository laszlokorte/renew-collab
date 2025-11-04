defmodule RenewCollabSim.Commands.ChangeShadowNetDocument do
  alias RenewCollabSim.Entities.ShadowNet
  import Ecto.Query

  defstruct [:shadow_net_system_id, :shadow_net_id, :document_json]

  def new(%{shadow_net_system_id: sns_id, shadow_net_id: net_id, document_json: document_json}) do
    %__MODULE__{shadow_net_system_id: sns_id, shadow_net_id: net_id, document_json: document_json}
  end

  def multi(%__MODULE__{
        shadow_net_system_id: sns_id,
        shadow_net_id: net_id,
        document_json: document_json
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      :shadow_net,
      from(sn in ShadowNet,
        where: sn.id == ^net_id and sn.shadow_net_system_id == ^sns_id
      )
    )
    |> Ecto.Multi.update(:change_net, fn %{shadow_net: net} ->
      ShadowNet.document_changeset(net, %{document_json: document_json})
    end)
  end
end
