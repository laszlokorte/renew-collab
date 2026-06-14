defmodule RenewCollabWeb.LiveDocumentsManager do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  use RenewCollabWeb, :live_view

  def mount(_params, _session, socket) do
    socket = socket |> assign(load_data(socket.assigns.current_account))

    {:ok, socket}
  end

  def load_data(account) do
    %{
      documents: %Views.GlobalDocumentsList{} |> Fetcher.fetch_as(account)
    }
  end

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <RenewCollabWeb.RenewComponents.app_header flash={@flash} />
      <div style="padding: 1em">
        Documents Management
        <h2 style="margin: 0; display: flex; align-items: center; gap: 1ex;">
          <img class="icon" src="/images/icon-document.svg" /> Manage Documents
        </h2>
      </div>
      
      <div style="padding: 1em">
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
                <td colspan="9">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Simulation yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {document, di} <- @documents |> Enum.with_index do %>
                <tr {if(rem(di, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td>
                    <.link
                      style="color: #078; display: flex; gap: 1ex;"
                      navigate={~p"/document/#{document.id}"}
                    >
                      <img class="icon" src="/images/icon-document.svg" /> {document.name}
                    </.link>
                  </td>
                  
                  <td><RenewCollabWeb.RenewComponents.timestamp value={document.inserted_at} /></td>
                  
                  <td><RenewCollabWeb.RenewComponents.timestamp value={document.inserted_at} /></td>
                  
                  <td width="50">
                    <a target="_blank" href={~p"/documents/#{document.id}/export"}>
                      <button style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff">
                        Export
                      </button>
                    </a>
                  </td>
                  
                  <td width="50">
                    <button
                      type="button"
                      phx-click="delete_document"
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
    </div>
    """
  end

  def handle_event("validate_document", params, socket) do
    {:noreply, assign(socket, create_form: to_form(params))}
  end

  def handle_event("delete_document", %{"id" => id}, socket) do
    %Actions.DocumentDeleteAsUser{document_id: id}
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Document deleted")
        |> reload()

      _ ->
        {:noreply,
         socket
         |> put_flash(:info, "Document deletion failed")}
    end
  end

  def handle_info(:any, socket) do
    socket |> reload()
  end

  def reload(socket) do
    {:noreply, socket |> assign(load_data(socket.assigns.current_account))}
  end
end
