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

  def channel_for(%Views.DocumentWithContent{document_id: doc_id}), do: "pub-document:#{doc_id}"
  def channel_for(%Views.DocumentVersionsList{document_id: doc_id}), do: "pub-document:#{doc_id}"
  def channel_for(%Views.DocumentVersionState{document_id: doc_id}), do: "pub-document:#{doc_id}"
  def channel_for(%Views.DocumentStripped{}), do: nil
  def channel_for(%Views.DocumentSimulationLinks{}), do: nil
  def channel_for(%Views.GlobalSocketSchemasList{}), do: "pub-global_socket_schemas"
  def channel_for(%Views.GlobalSocketSchemasMap{}), do: "pub-global_socket_schemas"
  def channel_for(%Views.GlobalSocketSchema{}), do: "pub-global_socket_schemas"
  def channel_for(%Views.GlobalSocketById{}), do: "pub-global_socket_schemas"
  def channel_for(%Views.GlobalSymbolsList{}), do: nil
  def channel_for(%Views.GlobalSymbolsMap{}), do: nil
  def channel_for(%Views.GlobalSymbol{}), do: nil
  def channel_for(%Views.GlobalSyntaxList{}), do: "pub-global_syntax"
  def channel_for(%Views.GlobalPrimitives{}), do: "pub-global_primitives"
  def channel_for(%Views.DocumentHierarchyMissings{}), do: nil
  def channel_for(%Views.DocumentHierarchyInvalids{}), do: nil
  def channel_for(%Views.SystemHealthReport{}), do: nil
  def channel_for(%Views.DocumentLayerRelative{}), do: nil
  def channel_for(%Views.DocumentLayerReachable{}), do: nil
  def channel_for(%Views.DocumentLayerHyperlinked{}), do: nil
  def channel_for(%Views.DocumentLayerGraphConnection{}), do: nil
  def channel_for(%Views.DocumentLayerRelativeMultiple{}), do: nil
  def channel_for(%Views.DocumentLayerConnectedComponent{}), do: nil
  def channel_for(%Views.GlobalAccounts{}), do: nil
  def channel_for(%Views.GlobalProjects{}), do: nil
  def channel_for(%Views.MyProject{project_id: proj_id}), do: "pub-project:#{proj_id}"

  def channel_for(%Views.ProjectSimulationsList{project_id: proj_id}),
    do: "pub-project-simulations:#{proj_id}"

  def channel_for(%Views.ProjectShadowNetSystemsList{project_id: proj_id}),
    do: "pub-project-shadow-net-systems:#{proj_id}"

  def channel_for(%Views.ProjectRunningSimulationIds{project_id: proj_id}),
    do: "projects/#{proj_id}/simulations"

  def channel_for(%Views.ShadowNetSystem{shadow_net_system_id: sns_id}),
    do: "pub-shadow-net-system:#{sns_id}"

  def channel_for(%Views.SimulationWithState{simulation_id: sim_id}), do: "simulation:#{sim_id}"
  def channel_for(%Views.ShadowNetSystemSimulations{}), do: nil

  def channel_for(%Views.GlobalProject{}), do: nil
  def channel_for(%Views.GlobalDocumentsList{}), do: nil
  def channel_for(%Views.GlobalSimulationsList{}), do: nil
  def channel_for(%Views.GlobalShadowNetSystemsList{}), do: nil
  def channel_for(%Views.GlobalProjectAllAssignments{}), do: nil
  def channel_for(%Views.SimulationWithLogEntries{}), do: nil
  def channel_for(%Views.SimulationNetInstance{}), do: nil
  def channel_for(%Views.ProjectInvitations{project_id: proj_id}), do: "pub-project:#{proj_id}"
  def channel_for(%Views.MediaData{}), do: nil
  def channel_for(_view), do: nil
end
