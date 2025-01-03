defmodule RenewCollab.Compatiblity.Multi do
  def insert(multi, name, changeset_or_struct_or_fun, opts \\ []) do
    Ecto.Multi.insert(multi, name, changeset_or_struct_or_fun, adjust_options(opts))
  end

  def insert_all(multi, name, schema_or_source, entries_or_query_or_fun, opts \\ []) do
    Ecto.Multi.insert_all(
      multi,
      name,
      schema_or_source,
      entries_or_query_or_fun,
      adjust_options(opts)
    )
  end

  RenewCollab.Repo.__adapter__()
  |> case do
    Ecto.Adapters.MyXQL ->
      defp adjust_options(opts) do
        remove_key(opts, :conflict_target)
      end

      defp remove_key(kw_list, key) do
        kw_list
        |> Enum.filter(fn
          {^key, _} -> false
          _ -> true
        end)
      end

    _ ->
      defp adjust_options(opts) do
        opts
      end
  end
end
