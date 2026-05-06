defmodule RenewCollabProj.Projects do
  @moduledoc """
  The Renew context.
  """
  alias RenewCollabAuth.Entities.Account

  def member_roles(), do: RenewCollabProj.Entities.ProjectMember.roles()

  def member_roles(%Account{is_admin: true}, _project),
    do: RenewCollabProj.Entities.ProjectMember.roles()
end
