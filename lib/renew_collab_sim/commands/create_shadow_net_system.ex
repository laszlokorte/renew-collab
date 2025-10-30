defmodule RenewCollabSim.Commands.CreateShadowNetSystem do
  alias RenewCollabSim.Entities.ShadowNetSystem

  defstruct [:label, :compiled, :main_net_name, :nets]

  def new(%{label: label, compiled: compiled, main_net_name: main_net_name, nets: nets}) do
    %__MODULE__{label: label, compiled: compiled, main_net_name: main_net_name, nets: nets}
  end

  def multi(%__MODULE__{
        label: label,
        compiled: compiled,
        main_net_name: main_net_name,
        nets: nets
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :shadow_net_system,
      %ShadowNetSystem{}
      |> ShadowNetSystem.changeset(%{
        "label" => label,
        "compiled" => compiled,
        "main_net_name" => main_net_name,
        "nets" => nets
      })
    )
  end
end
