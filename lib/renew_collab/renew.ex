defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Versioning.Snapshot
  alias RenewCollab.Repo
  alias RenewCollab.Commands

  alias RenewCollab.Document.Document
  alias RenewCollab.Document.TransientDocument
  alias RenewCollab.Simulation.SimulationLink

  alias RenewCollabProj.Entites.Project

  def list_documents(%Project{} = project) do
    RenewCollab.Queries.DocumentList.new(%{project: project})
    |> RenewCollab.Fetcher.fetch()
  end

  def list_documents() do
    []
  end

  def count_documents do
    RenewCollab.Queries.DocumentCount.new()
    |> RenewCollab.Fetcher.fetch()
  end

  def count_snapshots do
    from(s in Snapshot, select: count()) |> Repo.one()
  end

  def get_document(id), do: Repo.get(Document, id)

  def get_document_with_elements(document_id) do
    %{document_id: document_id}
    |> RenewCollab.Queries.DocumentWithElements.new()
    |> RenewCollab.Fetcher.fetch()
    |> RenewCollabProj.Projects.attach_project_assignment()
  end

  def create_document(project, attrs \\ %{}, parenthoods \\ [], hyperlinks \\ [], bonds \\ []) do
    Commands.CreateDocument.new(%{
      doc: %TransientDocument{
        content: attrs,
        parenthoods: parenthoods,
        hyperlinks: hyperlinks,
        bonds: bonds
      }
    })
    |> RenewCollab.Commander.run_document_command_sync()
    |> case do
      {:ok, %{insert_document: insert_document}} ->
        RenewCollabProj.Projects.assign_to_project(project, insert_document)

        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "project/#{project.id}/documents",
          :any
        )

        {:ok, insert_document}
    end
  end

  def delete_document(document_id) do
    RenewCollab.Commands.DeleteDocument.new(%{
      document_id: document_id
    })
    |> RenewCollab.Commander.run_document_command(false)

    RenewCollabProj.Projects.delete_document(document_id)
    |> case do
      %Project{id: project_id} ->
        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "project/#{project_id}/documents",
          :any
        )

      _ ->
        nil
    end
  end

  def duplicate_document(document_id) do
    RenewCollab.Commands.DuplicateDocument.new(%{
      document_id: document_id
    })
    |> RenewCollab.Commander.run_document_command_sync(true)
    |> case do
      {:ok, %{insert_document: new_document}} = res ->
        project = RenewCollabProj.Projects.find_documents_project(document_id)
        RenewCollabProj.Projects.assign_to_project(project, new_document)

        # TODO:broadcast
        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          "project/#{project.id}/documents",
          :any
        )

        res

      o ->
        o
    end
  end

  def list_simulation_links(document_id) do
    Repo.all(
      from(l in SimulationLink,
        where: l.document_id == ^document_id,
        order_by: [desc: l.inserted_at]
      )
    )
    |> RenewCollabSim.Repo.preload([:simulation])
  end
end
