defmodule RenewCollabCtrl.ReadAccess do
  alias RenewCollabCtrl.Views
  def can(_, _)

  def can(_account, %Views.ProjectMembersList{}), do: true
  def can(_account, %Views.ProjectDocumentsList{}), do: true
  def can(_account, %Views.DocumentWithContent{}), do: true
  def can(_account, %Views.DocumentVersionsList{}), do: true
  def can(_account, %Views.DocumentVersionState{}), do: true
  def can(_account, %Views.DocumentStripped{}), do: true
  def can(_account, %Views.DocumentSimulationLinks{}), do: true
  def can(_account, %Views.GlobalSocketSchemasList{}), do: true
  def can(_account, %Views.GlobalSocketSchema{}), do: true
  def can(_account, %Views.GlobalSocketById{}), do: true
  def can(_account, %Views.GlobalSymbolsList{}), do: true
  def can(_account, %Views.GlobalSymbol{}), do: true
  def can(_account, %Views.GlobalSyntaxList{}), do: true
  def can(_account, %Views.GlobalPrimitives{}), do: true
  def can(_account, %Views.DocumentHierarchyMissings{}), do: true
  def can(_account, %Views.DocumentHierarchyInvalids{}), do: true
  def can(_account, %Views.SystemHealthReport{}), do: true
  def can(_account, %Views.DocumentLayerRelative{}), do: true
  def can(_account, %Views.GlobalAccounts{}), do: true
  def can(_account, %Views.GlobalProjects{}), do: true
  def can(%{id: account_id}, %Views.MyProjectsList{account_id: account_id}), do: true
  def can(%{id: account_id}, %Views.MyProject{account_id: account_id}), do: true

  def can(_account, %Views.ProjectSimulationsList{}), do: true
  def can(_account, %Views.ProjectShadowNetSystemsList{}), do: true
  def can(_account, %Views.ShadowNetSystem{}), do: true
  def can(_account, %Views.SimulationWithState{}), do: true

  def can(_account, %Views.GlobalProject{}), do: true
  def can(_account, %Views.GlobalDocumentsList{}), do: true
  def can(_account, %Views.GlobalSimulationsList{}), do: true
  def can(_account, %Views.GlobalShadowNetSystemsList{}), do: true

  def can(_account, _view), do: false
end
