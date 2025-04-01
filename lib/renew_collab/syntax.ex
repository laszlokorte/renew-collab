defmodule RenewCollab.Syntax do
  alias RenewCollab.Repo
  alias RenewCollab.Syntax.SyntaxType
  import Ecto.Query, warn: false

  def find_all() do
    from(s in SyntaxType,
      left_join: at in assoc(s, :edge_whitelists),
      left_join: wl in assoc(s, :edge_auto_targets),
      left_join: d in assoc(s, :default),
      preload: [
        edge_whitelists: at,
        edge_auto_targets: wl,
        default: d
      ]
    )
    |> Repo.all()
  end
end
