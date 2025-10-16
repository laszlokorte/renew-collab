defmodule RenewCollabCtrl.Fetcher do
  alias RenewCollabCtrl.ReadAccess
  alias RenewCollabCtrl.Views

  def fetch_as(action, account) do
    if ReadAccess.can(account, action) do
      do_fetch(action)
    else
      :access_denied
    end
  end

  defp do_fetch(%Views.DocumentWithContent{}) do
    nil
  end

  defp do_fetch(%Views.ProjectDocumentsList{}) do
    []
  end
end
