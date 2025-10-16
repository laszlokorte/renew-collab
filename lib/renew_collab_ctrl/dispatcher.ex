defmodule RenewCollabCtrl.Dispatcher do
  alias RenewCollabCtrl.ReadAccess
  alias RenewCollabCtrl.Actions

  def perform_as(action, account) do
    if ReadAccess.can(account, action) do
      do_perform(action)
    end
  end

  defp do_perform(%Actions.ProjectAddSsnAsAdmin{}) do
  end
end
