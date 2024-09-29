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
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <header style="background: #333; color: #fff; padding: 1em">
        <h1 style="margin: 0; font-size: 1.3em; display: flex; align-items: center; gap: 1ex">
          <img src="/favicon.svg" style="width: 1.5em; height: 1.5em" /> Renew Web Editor
        </h1>
      </header>

      <div style="padding: 1em 1em 0; display: flex; align-items: start; gap: 1em">
        <fieldset style="margin-bottom: 1em">
          <p>Create a new Empty Document</p>
          <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
            New Empty Document
          </legend>
          <.form for={@create_form} phx-submit="create_document" phx-change="validate">
            <div style="display: flex; align-items: stretch; gap: 0.1em">
              <input
                type="text"
                name="name"
                placeholder="Untitled"
                value={@create_form[:name].value}
                id={@create_form[:name].id}
              />
              <button
                type="submit"
                style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff; padding: 1ex"
              >
                Create Document
              </button>
            </div>
          </.form>
        </fieldset>

        <fieldset style="margin-bottom: 1em">
          <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
            Import Renew (.rnw) Files
          </legend>
          <p>
            Select up to 10 Renew files from your computer:
          </p>
          <.form for={@import_form} phx-submit="import_document" phx-change="validate">
            <.live_file_input
              upload={@uploads.import_file}
              style="padding: 0.5em; background: #666; color: #fff; width: 100%; box-sizing: border-box;"
            />
            <%= unless Enum.empty?(@uploads.import_file.entries) do %>
              <dl style="display: grid; grid-template-columns: auto auto auto; justify-content: start; gap: 2px ; align-items: center">
                <%= for entry <- @uploads.import_file.entries do %>
                  <dt style="grid-column: 1; display: flex; gap: 1em">
                    <button
                      style="justify-content: center; text-align: center; font-weight: bold; cursor: pointer; width: 1.8em; height: 1.8em; display: flex; place-items: center; border: none; background: #a33; color: #fff; border-radius: 100%;"
                      type="button"
                      phx-click="cancel-upload"
                      phx-value-ref={entry.ref}
                      aria-label="cancel"
                    >
                      &times;
                    </button>
                    <%= entry.client_name %>
                  </dt>
                  <dd><%!-- entry.progress will update automatically for in-flight entries --%>
                    <progress value={entry.progress} max="100"><%= entry.progress %>%</progress></dd>
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

            <ul style="margin: 0; padding: 0;">
              <%= for err <- upload_errors(@uploads.import_file) do %>
                <li class="alert alert-danger"><%= error_to_string(err) %></li>
              <% end %>
            </ul>

            <%= if Enum.count(@uploads.import_file.entries) > 0 and Enum.count(@uploads.import_file.errors) == 0 do %>
              <button
                type="submit"
                style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff; padding: 1ex"
              >
                Import
              </button>
            <% end %>
          </.form>
        </fieldset>
      </div>

      <div style="padding: 1em">
        <h2 style="margin: 0;">Documents</h2>
        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="1000">Name</th>
              <th style="border-bottom: 1px solid #333;" align="left" width="200">Created</th>
              <th style="border-bottom: 1px solid #333;" align="left" width="200">Last Updated</th>
              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="3">
                Actions
              </th>
            </tr>
          </thead>
          <tbody>
            <%= if Enum.empty?(@documents) do %>
              <tr>
                <td colspan="6">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Documents yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {document, di} <- @documents |> Enum.with_index do %>
                <tr {if(rem(di, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <.link style="color: #078" navigate={~p"/document/#{document.id}"}>
                      <%= document.name %>
                    </.link>
                  </td>
                  <td><%= document.inserted_at |> Calendar.strftime("%Y-%m-%d %H:%M") %></td>
                  <td><%= document.updated_at |> Calendar.strftime("%Y-%m-%d %H:%M") %></td>
                  <td width="50">
                    <a href={~p"/documents/#{document.id}/export"}>
                      <button style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff">
                        Export
                      </button>
                    </a>
                  </td>
                  <td width="50">
                    <button
                      type="button"
                      phx-click="duplicate"
                      phx-value-id={document.id}
                      style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                    >
                      Duplicate
                    </button>
                  </td>
                  <td width="50">
                    <button
                      type="button"
                      phx-click="delete"
                      phx-value-id={document.id}
                      style="cursor: pointer; padding: 1ex; border: none; background: #a33; color: #fff"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              <% end %>
            <% end %>
          </tbody>
        </table>
      </div>
      <div style="padding: 1em">
        <details>
          <summary>
            <h2 style="margin: 0; display: inline; cursor: pointer;">System</h2>
          </summary>

          <fieldset>
            <legend>Reset</legend>
            <p>
              Clear all Documents and reset database content.
            </p>
            <button
              type="button"
              phx-click="reset"
              style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
            >
              Reinstall
            </button>
          </fieldset>
        </details>
      </div>
    </div>
    """
  end

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

  def handle_event("import_document", _params, socket) do
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
          with {:ok, %RenewCollab.Document.Document{}} <-
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
    with {:ok, %RenewCollab.Document.Document{}} <-
           RenewCollab.Renew.create_document(
             params
             |> Map.update("name", "", fn
               "" -> "untitled"
               n -> n
             end)
             |> Map.put("kind", "CH.ifa.draw.standard.StandardDrawing")
           ) do
    end

    {:noreply, socket}
  end

  def handle_event("reset", %{}, socket) do
    RenewCollab.Init.reset()

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

  def handle_info(%{topic: @topic, payload: _state}, socket) do
    {:noreply, socket |> assign(:documents, Renew.list_documents())}
  end
end
