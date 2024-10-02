defmodule RenewCollab.Commands.DeleteBond do
  import Ecto.Query, warn: false

  alias RenewCollab.Connection.Bond

  defstruct [:document_id, :bond_id]

  def new(%{
        document_id: document_id,
        bond_id: bond_id
      }) do
    %__MODULE__{
      document_id: document_id,
      bond_id: bond_id
    }
  end

  def multi(%__MODULE__{
        document_id: document_id,
        bond_id: bond_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.one(:bond, fn %{document_id: document_id} ->
      from(b in Bond,
        join: e in assoc(b, :element_edge),
        join: l in assoc(e, :layer),
        where: l.document_id == ^document_id and b.id == ^bond_id
      )
    end)
    |> Ecto.Multi.delete(:delete_bond, fn %{bond: bond} ->
      bond
    end)
  end
end
