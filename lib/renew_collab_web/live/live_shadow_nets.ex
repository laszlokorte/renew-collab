defmodule RenewCollabWeb.LiveShadowNets do
  use RenewCollabWeb, :live_view
  use RenewCollabWeb, :verified_routes

  @topic "shadow_nets"

  def mount(_params, _session, socket) do
    RenewCollabWeb.Endpoint.subscribe(@topic)

    socket =
      socket
      |> assign(:shadow_net_systems, RenewCollabSim.Simulator.list_shadow_net_systems())
      |> assign(import_form: to_form(%{"main_net" => nil}))
      |> allow_upload(:import_file, accept: ~w(.rnw), max_entries: 10)

    {:ok, socket}
  end

  def handle_info(:any, socket) do
    {:noreply,
     socket |> assign(:shadow_net_systems, RenewCollabSim.Simulator.list_shadow_net_systems())}
  end

  defp error_to_string(:too_large), do: "The selected file is too large."
  defp error_to_string(:too_many_files), do: "You have selected too many files."

  defp error_to_string(:not_accepted),
    do: "You have selected an unsupported file format. (only .rnw files can be imported)"

  def render(assigns) do
    ~H"""
    <div style="display: grid; position: absolute; left: 0;right:0;bottom:0;top:0; grid-auto-rows: auto; align-content: start;">
      <header style="background: #333; color: #fff; padding: 1em; display: flex; justify-content: space-between;">
        <h1 style="margin: 0; font-size: 1.3em; display: flex; align-items: center; gap: 1ex">
          <img src="/favicon.svg" style="width: 1.5em; height: 1.5em" /> Renew Web Editor
        </h1>
        <.link style="color: white; align-self: center;" navigate={~p"/"}>Dashboard</.link>
      </header>

      <div style="padding: 1em 1em 0; display: flex; align-items: start; gap: 1em">
        <fieldset style="margin-bottom: 1em">
          <legend style="background: #333;color:#fff;padding: 0.5ex; display: inline-block">
            Import Renew (.rnw) Files to Simulate
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
                    <input
                      type="radio"
                      name="main_net"
                      value={entry.ref}
                      checked={entry.ref == @import_form[:main_net].value}
                    />
                    <button
                      style="justify-content: center; text-align: center; font-weight: bold; cursor: pointer; width: 1.8em; height: 1.8em; display: flex; place-items: center; border: none; background: #a33; color: #fff; border-radius: 100%;"
                      type="button"
                      phx-click="cancel-upload"
                      phx-value-ref={entry.ref}
                      aria-label="cancel"
                    >
                      &times;
                    </button>
                    {entry.client_name}
                  </dt>

                  <dd>
                    <%!-- entry.progress will update automatically for in-flight entries --%>
                    <progress value={entry.progress} max="100">{entry.progress}%</progress>
                  </dd>

                  <dd style="grid-column: 1 / span 3;">
                    <ul>
                      <%= for err <- upload_errors(@uploads.import_file, entry) do %>
                        <li class="alert alert-danger">{error_to_string(err)}</li>
                      <% end %>
                    </ul>
                  </dd>
                <% end %>
              </dl>
            <% end %>

            <ul style="margin: 0; padding: 0;">
              <%= for err <- upload_errors(@uploads.import_file) do %>
                <li class="alert alert-danger">{error_to_string(err)}</li>
              <% end %>
            </ul>

            <%= if @import_form[:main_net].value != nil and Enum.count(@uploads.import_file.entries) > 0 and Enum.count(@uploads.import_file.errors) == 0 do %>
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
        <h2 style="margin: 0;">Shadow Net Systems</h2>

        <table style="width: 100%;" cellpadding="5">
          <thead>
            <tr>
              <th style="border-bottom: 1px solid #333;" align="left" width="1000">ID</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="1000">Main Net</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="1000">All Nets</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="200">Created</th>

              <th style="border-bottom: 1px solid #333;" align="left" width="200">
                Number of Simulations
              </th>

              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="2">
                Actions
              </th>
            </tr>
          </thead>

          <tbody>
            <%= if Enum.empty?(@shadow_net_systems) do %>
              <tr>
                <td colspan="7">
                  <div style="padding: 2em; border: 3px dashed #aaa; text-align: center; font-style: italic;">
                    No Shadow nets yet.
                  </div>
                </td>
              </tr>
            <% else %>
              <%= for {sns, si} <- @shadow_net_systems |> Enum.with_index do %>
                <tr {if(rem(si, 2) == 0, do: [style: "background-color:#f5f5f5;"], else: [])}>
                  <td width="100%">
                    <.link navigate={~p"/shadow_net/#{sns.id}"}>
                      <code>{sns.id}</code>
                    </.link>
                  </td>

                  <td valign="top">
                    <strong>{sns.main_net_name}</strong>
                  </td>

                  <td valign="top">
                    <ul style="list-style: none; margin: 0; padding: 0;">
                      <%= for n <- sns.nets do %>
                        <li>{n.name}</li>
                      <% end %>
                    </ul>
                  </td>

                  <td style="white-space: nowrap;">
                    {sns.inserted_at |> Calendar.strftime("%Y-%m-%d %H:%M")}
                  </td>

                  <td style="white-space: nowrap;">
                    {sns.simulation_count}
                  </td>

                  <td width="50">
                    <a style="color: #078" href={~p"/shadow_net/#{sns.id}/binary"}>
                      <button
                        type="button"
                        style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
                      >
                        Download SNS File
                      </button>
                    </a>
                  </td>

                  <td width="50">
                    <button
                      type="button"
                      phx-click="delete"
                      phx-value-id={sns.id}
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

  def handle_event("validate", params, socket) do
    default_main =
      socket.assigns.uploads.import_file.entries
      |> Enum.at(0)
      |> case do
        nil ->
          nil

        %{ref: ref} ->
          ref
      end

    {:noreply,
     socket
     |> assign(
       import_form:
         to_form(
           Map.update(params, "main_net", default_main, fn
             "" -> default_main
             v -> v
           end)
         )
     )}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    new_socket =
      socket
      |> cancel_upload(:import_file, ref)

    if(socket.assigns.import_form.params["main_net"] == ref) do
      {:noreply,
       new_socket
       |> assign(
         import_form:
           to_form(%{
             "main_net" =>
               new_socket.assigns.uploads.import_file.entries
               |> Enum.at(0)
               |> case do
                 nil ->
                   nil

                 %{ref: ref} ->
                   ref
               end
           })
       )}
    else
      {:noreply, new_socket}
    end
  end

  def handle_event("import_document", %{"main_net" => main_net_ref}, socket) do
    main_net_name =
      Enum.find_value(socket.assigns.uploads.import_file.entries, nil, fn
        %{ref: ^main_net_ref, client_name: client_name} ->
          Path.rootname(Path.basename(client_name))

        _ ->
          false
      end)

    paths =
      consume_uploaded_entries(socket, :import_file, fn %{path: path},
                                                        %{
                                                          client_name: filename
                                                        } ->
        {:ok, file_content} = File.read(path)
        {:ok, {Path.basename(filename), file_content}}
      end)

    RenewCollabSim.Simulator.compile_rnws_to_ssn(paths, main_net_name)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => sns_id}, socket) do
    RenewCollabSim.Simulator.delete_shadow_net_system(sns_id)

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      @topic,
      :any
    )

    {:noreply, socket}
  end
end
