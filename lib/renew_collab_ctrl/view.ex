defmodule RenewCollabCtrl.View do
  alias RenewCollabCtrl.Views

  def do_fetch(_account, %Views.DocumentLayerRelative{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.DocumentStripped{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.DocumentVersionState{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.DocumentVersionsList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.DocumentWithContent{document_id: document_id}) do
    %{document_id: document_id}
    |> RenewCollab.Queries.DocumentWithElements.new()
    |> RenewCollab.Queries.DocumentWithElements.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
    |> then(
      &case &1 do
        {:ok, list} -> {:ok, RenewCollabProj.Projects.attach_project_assignment(list)}
      end
    )
  end

  def do_fetch(_account, %Views.GlobalAccounts{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalDocumentCount{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalDocumentsList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.GlobalPrimitives{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalShadowNetsList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.GlobalSimulationsList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.GlobalSocketById{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSocketIdsByName{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSocketSchemasList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.GlobalSocketSchemasNames{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSymbolsList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.GlobalSymbolsNames{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.GlobalSyntaxList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.MyAccount{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.MyProjectsList{}) do
    {:error, []}
  end

  def do_fetch(account, %Views.ProjectDocumentsList{project_id: project_id}) do
    account
    |> RenewCollabProj.Projects.find_own_project(project_id)
    |> then(&RenewCollab.Queries.DocumentList.new(%{project: &1}))
    |> RenewCollab.Queries.DocumentList.multi()
    |> RenewCollab.Repo.transact()
    |> extract_result()
  end

  def do_fetch(_account, %Views.ProjectShadowNetSystemsList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.ProjectSimulationsList{}) do
    {:error, []}
  end

  def do_fetch(_account, %Views.ShadowNetSystemSimulations{}) do
    {:error, :not_implemented}
  end

  def do_fetch(_account, %Views.SimulationWithState{}) do
    {:error, :not_implemented}
  end

  defp extract_result({:ok, %{:result => res}}) do
    {:ok, res}
  end
end
