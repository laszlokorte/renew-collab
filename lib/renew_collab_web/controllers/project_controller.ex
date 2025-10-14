defmodule RenewCollabWeb.ProjectController do
  use RenewCollabWeb, :controller

  alias RenewCollabProj.Projects
  alias RenewCollab.Renew

  action_fallback(RenewCollabWeb.FallbackController)

  def index(conn, _params) do
    projects = Projects.list_own_projects(own_account(conn))
    render(conn, :index, projects: projects)
  end

  def show(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :show, project: project)
  end

  def members(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :members, project: project)
  end

  def documents(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :documents, project: project)
  end

  def simulations(conn, %{"id" => project_id}) do
    project = Projects.find_own_project(own_account(conn), project_id)
    render(conn, :simulations, project: project)
  end

  def export(conn, %{"id" => project_id} = params) do
    project = Projects.find_own_project(own_account(conn), project_id)

    files =
      for %{document: document} <- project.documents do
        doc_content = Renew.get_document_with_elements(document.id)
        {:ok, output} = RenewCollab.Export.DocumentExport.export(doc_content, synthetic: true)

        stripped_document =
          RenewCollab.Queries.StrippedDocument.new(%{
            document_id: document.id,
            original_ids: true
          })
          |> RenewCollab.Fetcher.fetch()
          |> Map.from_struct()
          |> Kernel.inspect(pretty: true, limit: :infinity)

        [
          {"renew/#{document.name}.rnw", output},
          {"ex/#{document.name}.ex", stripped_document}
        ]
      end
      |> Enum.concat(
        for %{shadow_net_system_id: sns_id} <- project.shadow_net_systems do
          import Ecto.Query

          sns_compiled =
            from(sns in RenewCollabSim.Entites.ShadowNetSystem,
              select: sns.compiled,
              where: sns.id == ^sns_id
            )
            |> RenewCollabSim.Repo.one()

          [
            {"shadow_net_systems/#{sns_id}.sns", sns_compiled}
          ]
        end
      )
      |> List.flatten()
      |> dedup_tuples()
      |> Enum.map(fn {name, content} -> {String.to_charlist(name), content} end)

    # Create zip in memory
    {:ok, {zip_name, zip_data}} =
      :zip.create("#{project.name}.zip" |> String.to_charlist(), files, [:memory])

    conn
    |> put_resp_header(
      "content-disposition",
      "#{if(Map.has_key?(params, "inline"), do: "inline", else: "attachment")}; filename=\"#{zip_name}.zip\""
    )
    |> put_resp_header(
      "content-type",
      "application/zip"
    )
    |> send_resp(200, zip_data)
  end

  def dedup_tuples(list) do
    {_, result} =
      Enum.reduce(list, {%{}, []}, fn {filename, val}, {counts, acc} ->
        count = Map.get(counts, filename, 0) + 1
        counts = Map.put(counts, filename, count)

        new_name =
          if count == 1 do
            filename
          else
            "#{Path.rootname(filename)}#{count}#{Path.extname(filename)}"
          end

        acc = [{new_name, val} | acc]
        {counts, acc}
      end)

    Enum.reverse(result)
  end

  defp own_account(%{assigns: %{current_account: current_account}}) do
    current_account
  end

  defp own_account(_) do
    nil
  end
end
