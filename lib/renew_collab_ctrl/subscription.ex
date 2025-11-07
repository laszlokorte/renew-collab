defmodule RenewCollabCtrl.Subscription do
  alias RenewCollabCtrl.Views
  def channel_for(view)

  def channel_for(%Views.MyProjectsList{account_id: account_id}),
    do: "pub-my-projects:#{account_id}"

  def channel_for(%Views.MyProjectInvitations{account_id: account_id}),
    do: "pub-my-invitations:#{account_id}"

  def channel_for(%Views.ProjectMembersList{}), do: nil

  def channel_for(%Views.ProjectDocumentsList{project_id: proj_id}),
    do: "pub-project-documents:#{proj_id}"

  def channel_for(%Views.DocumentWithContent{}), do: nil
  def channel_for(%Views.DocumentVersionsList{}), do: nil
  def channel_for(%Views.DocumentVersionState{}), do: nil
  def channel_for(%Views.DocumentStripped{}), do: nil
  def channel_for(%Views.DocumentSimulationLinks{}), do: nil
  def channel_for(%Views.GlobalSocketSchemasList{}), do: nil
  def channel_for(%Views.GlobalSocketSchema{}), do: nil
  def channel_for(%Views.GlobalSocketById{}), do: nil
  def channel_for(%Views.GlobalSymbolsList{}), do: nil
  def channel_for(%Views.GlobalSymbol{}), do: nil
  def channel_for(%Views.GlobalSyntaxList{}), do: nil
  def channel_for(%Views.GlobalPrimitives{}), do: nil
  def channel_for(%Views.DocumentHierarchyMissings{}), do: nil
  def channel_for(%Views.DocumentHierarchyInvalids{}), do: nil
  def channel_for(%Views.SystemHealthReport{}), do: nil
  def channel_for(%Views.DocumentLayerRelative{}), do: nil
  def channel_for(%Views.GlobalAccounts{}), do: nil
  def channel_for(%Views.GlobalProjects{}), do: nil
  def channel_for(%Views.MyProject{account_id: account_id}), do: nil

  def channel_for(%Views.ProjectSimulationsList{project_id: proj_id}),
    do: "pub-project-simulations:#{proj_id}"

  def channel_for(%Views.ProjectShadowNetSystemsList{}), do: nil
  def channel_for(%Views.ShadowNetSystem{}), do: nil
  def channel_for(%Views.SimulationWithState{}), do: nil

  def channel_for(%Views.GlobalProject{}), do: nil
  def channel_for(%Views.GlobalDocumentsList{}), do: nil
  def channel_for(%Views.GlobalSimulationsList{}), do: nil
  def channel_for(%Views.GlobalShadowNetSystemsList{}), do: nil
  def channel_for(%Views.GlobalProjectAllAssignments{}), do: nil
  def channel_for(%Views.SimulationWithLogEntries{}), do: nil
  def channel_for(%Views.SimulationNetInstance{}), do: nil
  def channel_for(%Views.ProjectInvitations{}), do: nil
  def channel_for(%Views.MediaData{}), do: nil
  def channel_for(_view), do: nil
end
