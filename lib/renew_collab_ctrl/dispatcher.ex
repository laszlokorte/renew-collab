defmodule RenewCollabCtrl.Dispatcher do
  alias RenewCollabCtrl.Access
  alias RenewCollabCtrl.Actions

  def perform_as(action, account) do
    if Access.can(account, action) do
      do_perform(action)
    end
  end

  defp do_perform(%Actions.ProjectAddSsnAsAdmin{}) do
  end
end
