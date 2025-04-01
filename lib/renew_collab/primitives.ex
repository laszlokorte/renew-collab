defmodule RenewCollab.Primitives do
  import Ecto.Query, warn: false
  alias RenewCollab.Primitives.PredefinedPrimitiveGroup
  alias RenewCollab.Repo

  def find_all() do
    from(g in PredefinedPrimitiveGroup,
      left_join: p in assoc(g, :primitives),
      preload: [primitives: p]
    )
    |> Repo.all()
  end
end
