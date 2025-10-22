defmodule RenewCollabCtrl.ReadAccess do
  alias RenewCollabCtrl.Views
  def can(_, _)

  def can(_account, %Views.ProjectDocumentsList{}), do: true
  def can(_account, %Views.DocumentWithContent{}), do: true
  def can(_account, %Views.DocumentVersionsList{}), do: true
  def can(_account, %Views.DocumentVersionState{}), do: true
  def can(_account, %Views.DocumentSimulationLinks{}), do: true
  def can(_account, %Views.GlobalSocketSchemasList{}), do: true
  def can(_account, %Views.GlobalSymbolsList{}), do: true
  def can(_account, %Views.DocumentHierarchyMissings{}), do: true
  def can(_account, %Views.DocumentHierarchyInvalids{}), do: true

  def can(_account, _view), do: false
end
