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
                    <%= entry.client_name %>
                  </dt>

                  <dd>
                    <%!-- entry.progress will update automatically for in-flight entries --%>
                    <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>
                  </dd>

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

              <th style="border-bottom: 1px solid #333;" align="left" width="100" colspan="3">
                Actions
              </th>
            </tr>

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
                    <strong><code><%= sns.id %></code></strong>
                  </td>

                  <td valign="top">
                    <strong><%= sns.main_net_name %></strong>
                  </td>

                  <td valign="top">
                    <ul style="list-style: none; margin: 0; padding: 0;">
                      <%= for n <- sns.nets do %>
                        <li><%= n.name %></li>
                      <% end %>
                    </ul>
                  </td>

                  <td style="white-space: nowrap;">
                    <%= sns.inserted_at |> Calendar.strftime("%Y-%m-%d %H:%M") %>
                  </td>

                  <td width="50">
                    <button
                      type="button"
                      phx-click="new-simulation"
                      value={sns.id}
                      style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                    >
                      New Simulation
                    </button>
                  </td>
                  <td width="50">
                    <.link
                      download="x"
                      style="color: #078"
                      href={~p"/shadow_net/#{sns.id}/binary?text"}
                    >
                      <button
                        type="button"
                        style="white-space: nowrap; cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
                      >
                        Download SNS File
                      </button>
                    </.link>
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

                <tr>
                  <td>
                    <table width="100%">
                      <thead>
                        <tr>
                          <th align="left" width="100%">Simulations</th>

                          <th align="left"></th>
                        </tr>
                      </thead>

                      <tbody>
                        <%= for sim <- sns.simulations do %>
                          <tr>
                            <td>
                              <.link navigate={~p"/simulation/#{sim.id}"}>
                                <%= sim.id %>
                              </.link>
                            </td>
                          </tr>
                        <% end %>
                      </tbody>
                    </table>
                  </td>

                  <td colspan="4"></td>
                </tr>
              <% end %>
            <% end %>
          </thead>
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
    uuid_dir = "#{UUID.uuid4(:default)}"
    {:ok, output_root} = Path.safe_relative_to(uuid_dir, System.tmp_dir!())
    output_root = Path.absname(output_root, System.tmp_dir!())

    {:ok, output_root_upload} = Path.safe_relative_to("uploads", output_root)

    {:ok, output_path} = Path.safe_relative_to("compiled.ssn", output_root)
    {:ok, script_path} = Path.safe_relative_to("compile-script", output_root)
    # dbg(script_path)

    output_root_upload = Path.absname(output_root_upload, output_root)
    output_path = Path.absname(output_path, output_root)
    script_path = Path.absname(script_path, output_root)

    main_net_name =
      Enum.find_value(socket.assigns.uploads.import_file.entries, nil, fn
        %{ref: ^main_net_ref, client_name: client_name} ->
          Path.rootname(Path.basename(client_name))

        _ ->
          false
      end)

    try do
      File.mkdir_p(output_root_upload)

      paths =
        consume_uploaded_entries(socket, :import_file, fn %{path: path},
                                                          %{
                                                            client_name: filename
                                                          } ->
          {:ok, target_path} = Path.safe_relative_to(Path.basename(filename), output_root_upload)
          target_path = Path.absname(target_path, output_root_upload)

          File.cp(path, target_path)
          {:ok, target_path}
        end)

      script_content =
        [
          "setFormalism Java Net Compiler",
          "ex ShadowNetSystem -a #{Enum.join(paths, " ")} -o #{output_path}"
        ]
        |> Enum.join("\n")

      # dbg(script_content)
      File.write!(script_path, script_content)

      with {:ok, 0} <- RenewCollabSim.Script.Runner.start_and_wait(script_path),
           {:ok, content} = File.read(output_path) do
        %RenewCollabSim.Entites.ShadowNetSystem{}
        |> RenewCollabSim.Entites.ShadowNetSystem.changeset(%{
          "compiled" => content,
          "main_net_name" => main_net_name,
          "nets" => Enum.map(paths, &%{"name" => Path.rootname(Path.basename(&1))})
        })
        |> RenewCollab.Repo.insert()

        Phoenix.PubSub.broadcast(
          RenewCollab.PubSub,
          @topic,
          :any
        )
      else
        _ ->
          :error
      end
    after
      File.rm(output_path)
      File.rm(script_path)
    end

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

  def handle_event("new-simulation", %{"value" => sns_id}, socket) do
    %RenewCollabSim.Entites.Simulation{
      shadow_net_system_id: sns_id
    }
    |> RenewCollab.Repo.insert()

    Phoenix.PubSub.broadcast(
      RenewCollab.PubSub,
      @topic,
      :any
    )

    {:noreply, socket}
  end
end
