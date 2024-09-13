defmodule RenewCollabWeb.LiveDocuments do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  alias RenewCollab.Renew

  @topic "documents"

  def mount(_params, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)

    socket =
      socket
      |> assign(:documents, Renew.list_documents())
      |> assign(import_form: to_form(%{}))
      |> allow_upload(:import_file, accept: ~w(.rnw), max_entries: 1)

    {:ok, socket}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  def render(assigns) do
    ~H"""
    <div>
      <h2>Documents</h2>

      <fieldset>
        <legend>Add</legend>
        <.form for={@import_form} phx-submit="create_document" phx-change="validate">
          <input type="text" name="name" value={@import_form[:name].value} id={@import_form[:name].id} />
          <.live_file_input upload={@uploads.import_file} />
          <button type="submit">Create Document</button>
        </.form>
        <%= for entry <- @uploads.import_file.entries do %>
        <%= for err <- upload_errors(@uploads.import_file, entry) do %>
          <p class="alert alert-danger"><%= error_to_string(err) %></p>
        <% end %>
        <% end %>
      </fieldset>

      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Created</th>
            <th>Last Updated</th>
          </tr>
        </thead>
        <tbody>
          <%= for document <- @documents do %> 
        <tr>
          <td><.link href={~p"/live/document/#{document.id}"}><%= document.name %></.link></td>
          <td><%= document.inserted_at %></td>
          <td><%= document.updated_at %></td>
          <td><button type="button" phx-click="duplicate" phx-value-id={document.id}>Duplicate</button></td>
          <td><button type="button" phx-click="delete" phx-value-id={document.id}>Delete</button></td>
        </tr>
      <% end %>
        </tbody>
      </table>


      <fieldset>
        <legend>System</legend>
              <button type="button" phx-click="reset">Reinstall</button>

      </fieldset>

    </div>
    """
  end

  def handle_event("duplicate", %{"id" => id}, socket) do
    # TODO
    {:noreply, socket}
  end

  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, import_form: to_form(params))}
  end

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()

  def handle_event("create_document", params, socket) do
    case consume_uploaded_entries(socket, :import_file, fn %{path: path},
                                                           %{client_name: filename} ->
           doc_name =
             case params do
               %{"name" => name} -> if(blank?(name), do: filename, else: name)
               _ -> filename
             end

           {:ok, content} = File.read(path)
           RenewCollab.Import.DocumentImport.import(doc_name, content)
         end) do
      [{:ok, %{"name" => doc_name} = document_params, hierarchy}] ->
        with {:ok, %RenewCollab.Document.Document{} = document} <-
               RenewCollab.Renew.create_document(document_params, hierarchy) do
          RenewCollabWeb.Endpoint.broadcast!(
            "documents",
            "document:new",
            Map.take(document, [:name, :kind, :id])
            |> Map.put("href", url(~p"/api/documents/#{document}"))
          )
        else
          _ ->
            with {:ok, %RenewCollab.Document.Document{} = document} <-
                   RenewCollab.Renew.create_document(%{"name" => doc_name, "kind" => "error"}) do
              RenewCollabWeb.Endpoint.broadcast!(
                "documents",
                "document:new",
                Map.take(document, [:name, :kind, :id])
                |> Map.put("href", url(~p"/api/documents/#{document}"))
              )
            end
        end

      [] ->
        with {:ok, %RenewCollab.Document.Document{} = document} <-
               RenewCollab.Renew.create_document(params |> Map.put("kind", "empty")) do
          RenewCollabWeb.Endpoint.broadcast!(
            "documents",
            "document:new",
            Map.take(document, [:name, :kind, :id])
            |> Map.put("href", url(~p"/api/documents/#{document}"))
          )
        end
    end

    {:noreply, socket}
  end

  def handle_event("reset", %{}, socket) do
    RenewCollab.Symbol.reset()
    RenewCollab.Renew.reset()
    RenewCollab.Auth.create_account("test@test.de", "secret")

    RenewCollabWeb.Endpoint.broadcast!(
      "documents",
      "all:deleted",
      %{}
    )

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Renew.delete_document(%RenewCollab.Document.Document{id: id})

    RenewCollabWeb.Endpoint.broadcast!(
      "documents",
      "document:deleted",
      %{"id" => id}
    )

    {:noreply, socket}
  end

  def handle_info(%{topic: @topic, payload: state}, socket) do
    {:noreply, socket |> assign(:documents, Renew.list_documents())}
  end
end
