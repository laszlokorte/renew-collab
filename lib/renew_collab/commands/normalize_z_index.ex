defmodule RenewCollab.Commands.NormalizeZIndex do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer

  defstruct [:document_id]

  def new(%{
        document_id: document_id
      }) do
    %__MODULE__{
      document_id: document_id
    }
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}]

  def auto_snapshot(%__MODULE__{}), do: true

  def multi(
        %__MODULE__{
          document_id: document_id
        },
        nested \\ false
      ) do
    doc_id_key = if(nested, do: :normalize_z_index_document_id, else: :document_id)

    Ecto.Multi.new()
    |> Ecto.Multi.put(doc_id_key, document_id)
    |> Ecto.Multi.insert_all(
      :normalize_z_index,
      Layer,
      fn
        %{^doc_id_key => document_id} ->
          from(l in Layer,
            left_join: dp in assoc(l, :direct_parent_layer),
            where: l.document_id == ^document_id,
            select: %{
              inserted_at: ^DateTime.utc_now(),
              updated_at: ^DateTime.utc_now(),
              document_id: l.document_id,
              id: l.id,
              z_index: over(row_number(), :par)
            },
            windows: [par: [partition_by: dp.id, order_by: [asc: l.z_index]]]
          )
      end,
      on_conflict: {:replace, [:z_index]},
      conflict_target: :id
    )
  end
end
