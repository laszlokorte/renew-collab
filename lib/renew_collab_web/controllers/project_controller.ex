defmodule RenewCollabWeb.ProjectController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  action_fallback(RenewCollabWeb.FallbackController)

  def index(conn, _params) do
    projects =
      %Views.MyProjectsList{account_id: conn.assigns.current_account.id}
      |> Fetcher.fetch_as(conn.assigns.current_account)

    render(conn, :index, projects: projects)
  end

  def create(conn, %{}) do
    %Actions.ProjectCreateAsUser{
      project_name: "New Project",
      account_id: conn.assigns.current_account.id
    }
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      {:ok, new_project} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/projects/#{new_project}")
        |> json(%{
          id: new_project.id,
          url: url(~p"/api/projects/#{new_project}"),
          content: %{name: new_project.name}
        })
    end
  end

  def show(conn, %{"id" => project_id}) do
    account = conn.assigns.current_account

    project =
      %Views.MyProject{
        account_id: account.id,
        project_id: project_id
      }
      |> Fetcher.fetch_as(account)

    render(conn, :show, project: project)
  end

  def members(conn, %{"id" => project_id}) do
    account = conn.assigns.current_account

    project =
      %Views.MyProject{
        account_id: account.id,
        project_id: project_id
      }
      |> Fetcher.fetch_as(account)

    render(conn, :members, project: project)
  end

  def documents(conn, %{"id" => project_id}) do
    account = conn.assigns.current_account

    project =
      %Views.MyProject{
        account_id: account.id,
        project_id: project_id
      }
      |> Fetcher.fetch_as(account)

    render(conn, :documents, project: project)
  end

  def simulations(conn, %{"id" => project_id}) do
    account = conn.assigns.current_account

    project =
      %Views.MyProject{
        account_id: account.id,
        project_id: project_id
      }
      |> Fetcher.fetch_as(account)

    render(conn, :simulations, project: project)
  end

  def export(conn, %{"id" => project_id} = params) do
    project =
      %Views.MyProject{project_id: project_id, account_id: conn.assigns.current_account.id}
      |> Fetcher.fetch_as(conn.assigns.current_account)

    files =
      for %{document_id: document_id} <- project.documents do
        doc_content =
          %Views.DocumentWithContent{
            document_id: document_id
          }
          |> Fetcher.fetch_as(conn.assigns.current_account)

        {:ok, output} = RenewCollab.Export.DocumentExport.export(doc_content, synthetic: true)

        stripped_document =
          %Views.DocumentStripped{
            document_id: document_id,
            original_ids: true
          }
          |> Fetcher.fetch_as(conn.assigns.current_account)
          |> Map.from_struct()
          |> Kernel.inspect(pretty: true, limit: :infinity)

        [
          {"renew/#{doc_content.name}.rnw", output},
          {"ex/#{doc_content.name}.ex", stripped_document}
        ]
      end
      |> Enum.concat(
        for %{shadow_net_system_id: sns_id} <- project.shadow_net_systems do
          import Ecto.Query

          sns_compiled =
            from(sns in RenewCollabSim.Entities.ShadowNetSystem,
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
      |> Enum.concat([
        {"info.txt", "Project: #{project.name} (#{project.id})"}
      ])
      |> Enum.map(fn {name, content} ->
        {String.to_charlist("#{project.id}/#{name}"), content}
      end)

    # Create zip in memory
    {:ok, {zip_name, zip_data}} =
      :zip.create("#{project.name}.zip" |> String.to_charlist(), files, [:memory])

    conn
    |> put_resp_header(
      "content-disposition",
      "#{if(Map.has_key?(params, "inline"), do: "inline", else: "attachment")}; filename=\"#{zip_name}\""
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
end
