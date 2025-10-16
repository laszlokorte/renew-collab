defmodule RenewCollabCtrl.ReadAccess do
  alias RenewCollabCtrl.Views
  def can(_, _)

  def can(_account, %Views.ProjectDocumentsList{}), do: true

  def can(_account, _view), do: false
end
