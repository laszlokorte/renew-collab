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

  def do_fetch(_account, %Views.DocumentWithContent{}) do
    {:error, :not_implemented}
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

  def do_fetch(_account, %Views.ProjectDocumentsList{}) do
    {:ok, []}
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
end
