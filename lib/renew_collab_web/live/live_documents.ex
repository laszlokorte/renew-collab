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
      |> assign(create_form: to_form(%{}))
      |> assign(import_form: to_form(%{}))
      |> allow_upload(:import_file, accept: ~w(.rnw), max_entries: 10)

    {:ok, socket}
  end

  defp error_to_string(:too_large), do: "The selected file is too large."
  defp error_to_string(:too_many_files), do: "You have selected too many files."

  defp error_to_string(:not_accepted),
    do: "You have selected an unsupported file format. (only .rnw files can be imported)"

  def render(assigns) do
    ~H"""
    <div>
      <h1>Renew Online</h1>

      <fieldset>
        <legend>New Document</legend>
        <.form for={@create_form} phx-submit="create_document" phx-change="validate">
          <input type="text" name="name" placeholder="Document Name" value={@create_form[:name].value} id={@create_form[:name].id} />
          <button type="submit">Create Document</button>
        </.form>
      </fieldset>


      <fieldset>
        <legend>Import Renew (.rnw) Files</legend>
        <.form for={@import_form} phx-submit="import_document" phx-change="validate">
          <.live_file_input upload={@uploads.import_file} />
          <%= unless Enum.empty?(@uploads.import_file.entries) do %>
          <dl style="display: grid; grid-template-columns: auto auto auto; justify-content: start;">
           <%= for entry <- @uploads.import_file.entries do %>
              <dt style="grid-column: 1">        <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} aria-label="cancel">&times;</button>
    <%= entry.client_name %></dt>
              <dd><%!-- entry.progress will update automatically for in-flight entries --%>
        <progress value={entry.progress} max="100"> <%= entry.progress %>% </progress></dd>
        <dd style="grid-column: 1 / span 3;">
          <ul>
            <%= for err <- upload_errors(@uploads.import_file, entry) do %>
              <li class="alert alert-danger"><%= error_to_string(err) %></li>
            <% end %>
          </ul>
          </dd>
          <% end %>
          </dl>
          <% end %>

          <ul>
            <%= for err <- upload_errors(@uploads.import_file) do %>
              <li class="alert alert-danger"><%= error_to_string(err) %></li>
            <% end %>
          </ul>

          <%= if Enum.count(@uploads.import_file.entries) > 0 and Enum.count(@uploads.import_file.errors) == 0 do %>
          <button type="submit">Import</button>
          <% end %>
        </.form>
       
      </fieldset>



      <h2>Documents</h2>
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

      <h2>System</h2>

      <fieldset>
        <legend>Setup</legend>
        <p>
          Clear all Documents and reset database content.
        </p>
        <button type="button" phx-click="reset">Reinstall</button>
      </fieldset>

    </div>
    """
  end

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()

  def handle_event("duplicate", %{"id" => id}, socket) do
    RenewCollab.Renew.duplicate_document(id)
    {:noreply, socket}
  end

  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, import_form: to_form(params))}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :import_file, ref)}
  end

  def handle_event("import_document", params, socket) do
    case consume_uploaded_entries(socket, :import_file, fn %{path: path},
                                                           %{client_name: filename} ->
           {:ok, content} = File.read(path)
           RenewCollab.Import.DocumentImport.import(filename, content)
         end) do
      [_ | _] = converted_docs ->
        for %RenewCollab.Import.Converted{
              name: doc_name,
              kind: kind,
              layers: layers,
              hierarchy: hierarchy,
              hyperlinks: hyperlinks,
              bonds: bonds
            } <- converted_docs do
          with {:ok, %RenewCollab.Document.Document{} = document} <-
                 RenewCollab.Renew.create_document(
                   %{"name" => doc_name, "kind" => kind, "layers" => layers},
                   hierarchy,
                   hyperlinks,
                   bonds
                 ) do
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
        end
    end

    {:noreply, socket}
  end

  def handle_event("create_document", params, socket) do
    with {:ok, %RenewCollab.Document.Document{} = document} <-
           RenewCollab.Renew.create_document(
             params
             |> Map.update("name", "", fn
               "" -> "untitled"
               n -> n
             end)
             |> Map.put("kind", "empty")
           ) do
    end

    {:noreply, socket}
  end

  def handle_event("reset", %{}, socket) do
    RenewCollab.Renew.reset()
    RenewCollab.Auth.create_account("test@test.de", "secret")
    RenewCollab.Symbol.reset()

    RenewCollabWeb.Endpoint.broadcast!(
      "documents",
      "all:deleted",
      %{}
    )

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Renew.delete_document(%RenewCollab.Document.Document{id: id})

    {:noreply, socket}
  end

  def handle_info(%{topic: @topic, payload: state}, socket) do
    {:noreply, socket |> assign(:documents, Renew.list_documents())}
  end
end
