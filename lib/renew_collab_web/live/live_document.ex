defmodule RenewCollabWeb.LiveDocument do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabProj.Entities.ProjectDocument
  use RenewCollabWeb, :live_view

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Actions
  alias RenewCollabWeb.SimulationError

  import RenewCollabWeb.RenewComponents

  use RenewCollabCtrl.Helper,
    document: {Views.DocumentWithContent, [:document_id], :document_modified},
    undo_redo: {:async, Views.DocumentVersionState, [:document_id], :document_modified},
    other_documents: {:async, Views.ProjectDocumentsList, [:project_id], :documents_changed},
    snapshots: {:async, Views.DocumentVersionsList, [:document_id], :document_modified},
    socket_schemas: {:async, Views.GlobalSocketSchemasMap, [], :socket_schema_changed},
    symbols: {:async, Views.GlobalSymbolsMap, [], :symbols_changed},
    syntax_types: {Views.GlobalSyntaxList, [], :syntax_changed},
    hierachy_missing: {:async, Views.DocumentHierarchyMissings, [:document_id], :never},
    hierachy_invalid: {:async, Views.DocumentHierarchyInvalids, [:document_id], :never},
    simulation_links:
      {:async, Views.DocumentSimulationLinks, [:document_id], :simulations_changed}

  def load_param(:account_id, socket), do: socket.assigns.current_account.id
  def load_param(:project_id, socket), do: socket.assigns.document.project_assignment.project_id
  def load_param(:document_id, socket), do: socket.assigns.document_id
  def load_param(:account, socket), do: socket.assigns.account

  @renew_grammar Renewex.Grammar.new(11)

  def renew_grammar do
    @renew_grammar
  end

  def mount(%{"id" => document_id}, _session, socket) do
    socket
    |> assign(:document_id, document_id)
    |> load_data(true)
    |> case do
      {:ok, %{assigns: %{document: document}} = sock} ->
        sock
        |> assign(import_form: to_form(%{}))
        |> allow_upload(:import_file, accept: ~w(.rnw), max_entries: 1)
        |> assign(:auto_adjust_viewbox, false)
        |> assign(:selection, nil)
        |> assign(:show_hierarchy, false)
        |> assign(:show_selected, false)
        |> assign(:show_snapshots, false)
        |> assign(:show_health, false)
        |> assign(:show_simulations, false)
        |> assign(:show_meta, false)
        |> assign(:show_grid, false)
        |> assign(:viewbox, viewbox(document))
        |> then(&{:ok, &1})
    end
  end

  def render(assigns) do
    ~H"""
    <div style="position: absolute; top:0;left:0;bottom: 0; right:0;display: grid; width: 100vw; height: 100vh;
    grid-template-rows: [head-start ] auto [head-end top-start right-start] auto [top-end left-start ] 1fr [left-end right-end];
    grid-template-columns: [head-start left-start top-start]1fr [top-end left-end right-start]auto [head-end right-end];">
      <div style="grid-area: head">
        <RenewCollabWeb.RenewComponents.app_header
          flash={@flash}
          project_id={@document.project_assignment && @document.project_assignment.project_id}
          tab={:documents}
        />
      </div>

      <div style="grid-area: top; padding: 1em; background: #555; color: #fff; display: flex; justify-content: space-between; align-items: stretch;">
        <div>
          <.link navigate={~p"/projects"} style="color: inherit">Projects</.link>
          <%= case @document.project_assignment do %>
            <% %ProjectDocument{project_id: project_id} -> %>
              /
              <.link navigate={~p"/project/#{project_id}/documents"} style="color: inherit">
                Documents
              </.link>
              / Document
            <% _ -> %>
          <% end %>

          <div style="display: flex; gap: 1ex; align-items: center;">
            <img
              class="icon"
              src={"/documents/#{@document.id}/thumbnail?v=#{@document.thumbnail && @document.thumbnail.layer_id}"}
            />
            <h2 style="margin: 0;">{@document.name}</h2>
          </div>
        </div>

        <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: undo_redo} <- @undo_redo do %>
          <.live_component
            id="undo_redo"
            module={RenewCollabWeb.UndoRedoComponent}
            undo_redo={undo_redo}
          />
          <% else _ -> %>
        <% end %>
      </div>

      <div style="grid-area: left; width: 100%; height: 100%; overflow: auto; box-sizing: border-box; padding: 0; display: grid;">
        <datalist id="all-semantic-tags">
          <%= for {class_name, _} <- renew_grammar().hierarchy do %>
            <option>{class_name}</option>
          <% end %>
        </datalist>
        <%= if @show_grid do %>
          <div style="font-family: sans-serif; grid-area: 1 / 1 / span 1 / span 1; display: block; width: 100%; height: 100%;background: #f5f5f5;z-index: 100;">
            <table width="100%" border="1" cellspacing="0">
              <tr>
                <th>Source/Target</th>

                <.layers filter={:box} document={@document}>
                  <:item :let={layer}>
                    <th
                      phx-click="select_layer"
                      phx-value-id={layer.id}
                      bgcolor={if(layer.id == @selection, do: "#99ddff", else: "white")}
                    >
                      <small style="font-weight: normal;">
                        {layer.semantic_tag |> String.split(".") |> Enum.at(-1)}<br />
                        <span style="font-size: 10px; font-family: monospace">{layer.id}</span>
                      </small>
                    </th>
                  </:item>
                </.layers>
              </tr>

              <.layers filter={:box} document={@document}>
                <:item :let={layer_a = %{id: layer_a_id}}>
                  <tr>
                    <th
                      phx-click="select_layer"
                      phx-value-id={layer_a.id}
                      bgcolor={if(layer_a.id == @selection, do: "#99ddff", else: "white")}
                    >
                      <small style="font-weight: normal;">
                        {layer_a.semantic_tag |> String.split(".") |> Enum.at(-1)}<br />
                        <span style="font-size: 10px; font-family: monospace">{layer_a.id}</span>
                      </small>
                      <div>
                        <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: socket_schemas} <- @socket_schemas do %>
                          <select
                            phx-hook="RnwAssignInterface"
                            rnw-layer-id={"#{layer_a.id}"}
                            id={"layer-interface-#{layer_a.id}"}
                            name="socket_schema_id"
                          >
                            <option
                              value=""
                              {if(is_nil(layer_a.interface), do: [selected: "selected"], else: [])}
                            >
                              ---
                            </option>

                            <%= for {_sid, s} <- socket_schemas do %>
                              <option
                                value={s.id}
                                {if(layer_a.interface && s.id == layer_a.interface.socket_schema_id, do: [selected: "selected"], else: [])}
                              >
                                {s.name}
                              </option>
                            <% end %>
                          </select>
                          <% else _ -> %>
                            Loading...
                        <% end %>
                      </div>
                    </th>

                    <.layers filter={:box} document={@document}>
                      <:item :let={layer_b = %{id: layer_b_id}}>
                        <td align="center">
                          <%= for edge_layer = %{edge: %{source_bond: %{layer_id: ^layer_a_id}, target_bond: %{layer_id: ^layer_b_id}}} <- @document.layers do %>
                            <div style="display: flex; gap: 1ex; padding: 1ex; align-items: center;">
                              <button phx-click="delete_layer" phx-value-id={edge_layer.id}>X</button> {edge_layer.semantic_tag
                              |> String.split(".")
                              |> Enum.at(-1)}
                            </div>
                          <% end %>

                          <div>
                            <%= if layer_a.id != layer_b.id and (not (is_nil(layer_a.box) or is_nil(layer_b.box) or is_nil(layer_a.interface) or is_nil(layer_b.interface))) do %>
                              Connect:
                              <form phx-submit="create_grid_edge">
                                <input type="hidden" name="source_layer_id" value={layer_a.id} />
                                <input type="hidden" name="target_layer_id" value={layer_b.id} />
                                <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: socket_schemas} <- @socket_schemas do %>
                                  <select style="width: 5em" name="source_socket_id">
                                    <%= with schema <- socket_schemas |> Map.get(layer_a.interface.socket_schema_id, []) do %>
                                      <optgroup label={schema.name}>
                                        <%= for sock <- schema.sockets do %>
                                          <option value={sock.id}>{sock.name}</option>
                                        <% end %>
                                      </optgroup>
                                    <% end %>
                                  </select>
                                  <% else _ -> %>
                                    Loading...
                                <% end %>

                                <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: socket_schemas} <- @socket_schemas do %>
                                  <select style="width: 5em" name="target_socket_id">
                                    <%= with schema <- socket_schemas |> Map.get(layer_b.interface.socket_schema_id, []) do %>
                                      <optgroup label={schema.name}>
                                        <%= for sock <- schema.sockets do %>
                                          <option value={sock.id}>{sock.name}</option>
                                        <% end %>
                                      </optgroup>
                                    <% end %>
                                  </select>
                                  <% else _ -> %>
                                    Loading...
                                <% end %>
                                 <button>Connect</button>
                              </form>
                            <% end %>
                          </div>
                        </td>
                      </:item>
                    </.layers>
                  </tr>
                </:item>
              </.layers>

              <tr>
                <th>
                  <button
                    type="button"
                    phx-click="create_box"
                    phx-value-example="yes"
                    style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
                  >
                    Create Box
                  </button>
                </th>
              </tr>
            </table>
          </div>
        <% end %>

        <svg
          phx-click="select_layer"
          phx-value-id=""
          preserveAspectRatio="xMidYMin meet"
          id={"document-#{@document.id}"}
          viewBox={RenewCollab.ViewBox.into_string(RenewCollab.ViewBox.stretch(@viewbox))}
          style="grid-area: 1 / 1 / span 1 / span 1; display: block; width: 100%; height: 100%;background: #f5f5f5;"
          width={@viewbox.width}
          height={@viewbox.height}
        >
          <rect
            x={@viewbox.x}
            y={@viewbox.y}
            width={@viewbox.width}
            height={@viewbox.height}
            fill="#fff"
            stroke="#aaa"
            stroke-width="2"
          />
          <%= for layer <- @document.layers, layer.direct_parent_hood == nil do %>
            <.live_component
              selectable={true}
              id={layer.id}
              module={RenewCollabWeb.HierarchyLayerComponent}
              socket_schemas={@socket_schemas}
              document={@document}
              layer={layer}
              selection={@selection}
              selected={@selection == layer.id}
              symbols={@symbols}
            />
          <% end %>
        </svg>
      </div>

      <div style="grid-area: right;width: 100%; height: 100%; overflow: auto; box-sizing: border-box; padding: 0 2em; background: #eee">
        <p>
          <button
            phx-click="update-viewbox"
            style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
          >
            Refit Camera
          </button>
          <button
            style={"border: none; padding: 1ex; color: #fff; background-color: #{if(@show_grid, do: "#33ae33", else: "black")}; cursor: pointer"}
            phx-click="toggle-grid"
          >
            Grid
          </button>
        </p>

        <button
          phx-click="make-space"
          style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
        >
          Make Space
        </button>
        <div style="display: flex; gap: 1ex; padding: 1ex 0; height: 2em; box-sizing: border-box">
          <form target="" phx-change="insert_document">
            <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: other_documents} <- @other_documents do %>
              <select name="document_id" onchange="this.value=''">
                <option value="" selected>Insert Other Document</option>

                <%= for doc <- other_documents, doc.id != @document.id do %>
                  <option value={doc.id}>{doc.name}</option>
                <% end %>
              </select>
              <% else _ -> %>
                <select readonly="readonly" disabled="disabled" inert>
                  <option value="" selected disabled="disabled">Loading Document Picker...</option>
                </select>
            <% end %>
          </form>
        </div>

        <div style="display: flex; gap: 1ex; padding: 1ex 0">
          <button
            type="button"
            phx-click="wrap_in_group"
            disabled={is_nil(@selection)}
            phx-value-layer_id={@selection}
            style={"#{if(is_nil(@selection), do: "opacity: 0.3;", else: "cursor: pointer;")} padding: 1ex; border: none; background: #3a3; color: #fff"}
          >
            Wrap in Group
          </button>
          <button
            type="button"
            phx-click="create_group"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Create Group
          </button>
          <button
            type="button"
            phx-click="create_text"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Create Text
          </button>
          <button
            type="button"
            phx-click="create_box"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Create Box
          </button>
          <button
            type="button"
            phx-click="create_edge"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff"
          >
            Create Line
          </button>
        </div>

        <div style="display: flex; gap: 1ex; padding: 1ex 0">
          <button
            type="button"
            phx-click="create_transition"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a9; color: #fff"
          >
            Create Transition
          </button>
          <button
            type="button"
            phx-click="create_place"
            phx-value-example="yes"
            style="cursor: pointer; padding: 1ex; border: none; background: #3a9; color: #fff"
          >
            Create Place
          </button>
          <button
            disabled={is_nil(@selection)}
            type="button"
            phx-click="create_linked_text"
            phx-value-example="yes"
            style={"#{if(is_nil(@selection), do: "opacity: 0.3;", else: "cursor: pointer;")} padding: 1ex; border: none; background: #3a3; color: #fff;"}
          >
            Create Inscription
          </button>
          <form phx-submit="simulate">
            <label style="display: grid; grid-template-columns: 6em;">
              <button
                type="submit"
                phx-disable-with="Compiling..."
                style="grid-area: 1/1/-1/-1;cursor: pointer; padding: 1ex; border: none; background: #a3a; color: #fff"
              >
                Simulate
              </button>
              <select
                onchange="this.previousElementSibling.click()"
                name="formalism"
                style="cursor: pointer; grid-area: 1/1/-1/-1;opacity: 0; stretch; align-self: stretch;"
              >
                <option selected>---cancel---</option>

                <%= for f <- RenewCollabSim.Compiler.SnsCompiler.formalisms() do %>
                  <option>{f}</option>
                <% end %>
              </select>
            </label>
          </form>
        </div>

        <div>
          <.form for={@import_form} phx-submit="import_document" phx-change="validate-import">
            <label>Import Rnw:<br /> <.live_file_input upload={@uploads.import_file} /></label>
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
                    </button> {entry.client_name}
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

            <%= if Enum.count(@uploads.import_file.entries) > 0 and Enum.count(@uploads.import_file.errors) == 0 do %>
              <button
                type="submit"
                style="cursor: pointer; padding: 1ex; border: none; background: #3a3; color: #fff; padding: 1ex"
              >
                Import
              </button>
            <% end %>
          </.form>
        </div>

        <h2 style="cursor: pointer;" phx-click="toggle-meta">
          <span>{if(@show_meta, do: "▼", else: "►")}</span> Document
        </h2>

        <%= if @show_meta do %>
          <div style="width: 45vw;">
            <form id={"document-rename-#{@document.id}"} phx-hook="RnwDocumentRename">
              <dl style="display: grid; grid-template-columns: auto 1fr;gap:1ex; align-items: baseline">
                <dt style="margin: 0; text-align: right;">Document Id</dt>

                <dd style="margin: 0;">
                  <input
                    readonly
                    disabled
                    type="text"
                    value={@document.id}
                    style="padding: 1ex; box-sizing:border-box; width: 100%;"
                  />
                  <.link
                    target="_blank"
                    style="color: #078"
                    navigate={~p"/documents/#{@document.id}/inspect"}
                  >
                    Inspect
                  </.link>
                </dd>

                <dt style="margin: 0; text-align: right;">Document Name</dt>

                <dd style="margin: 0;">
                  <input
                    type="text"
                    name="name"
                    value={@document.name}
                    style="padding: 1ex; box-sizing:border-box; width: 100%;"
                  />
                </dd>

                <dt style="margin: 0; text-align: right;">Kind</dt>

                <dd style="margin: 0;">
                  <input
                    type="text"
                    name="kind"
                    value={@document.kind}
                    style="padding: 1ex; box-sizing:border-box; width: 100%;"
                    list="all-semantic-tags"
                  />
                </dd>

                <dt style="margin: 0; text-align: right;">Syntax</dt>

                <dd style="margin: 0;">
                  <select
                    type="text"
                    name="syntax_id"
                    style="padding: 1ex; box-sizing:border-box; width: 100%;"
                  >
                    <option value="none">None</option>

                    <%= for s <-  @syntax_types do %>
                      <option selected={@document.syntax_id == s.id} value={s.id}>{s.name}</option>
                    <% end %>
                  </select>
                </dd>

                <dt style="margin: 0; text-align: right;"></dt>

                <dd style="margin: 0;">
                  <button
                    style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
                    type="submit"
                  >
                    Save
                  </button>
                </dd>
              </dl>
            </form>
          </div>
           <hr />
          <button
            type="button"
            phx-click="remove_thumbnail"
            style="cursor: pointer; padding: 1ex; border: none; background: #933; color: #fff"
          >
            Remove Thumbnail
          </button>
        <% end %>

        <h2
          {if(@selection, do: [style: "cursor: pointer;"], else: [style: "cursor: pointer; color: #aaa"])}
          phx-click="toggle-selected"
        >
          <span>{if(@show_selected, do: "▼", else: "►")}</span> Selected
        </h2>

        <%= if @show_selected do %>
          <div style="width: 45vw;">
            <%= with selected_layer when selected_layer != nil <- Enum.find(@document.layers, &(&1.id == @selection)) do %>
              <.live_component
                id="layer-properties"
                module={RenewCollabWeb.LayerPropertiesComponent}
                socket_schemas={@socket_schemas}
                document={@document}
                symbols={@symbols}
                layer={selected_layer}
              />
            <% end %>
          </div>
        <% end %>

        <h2 style="cursor: pointer;" phx-click="toggle-hierarchy">
          <span>{if(@show_hierarchy, do: "▼", else: "►")}</span> Hierarchy
        </h2>

        <%= if @show_hierarchy do %>
          <%= if not is_nil(@selection) do %>
            <div style="padding: 1ex 0; display: flex; gap: 1ex">
              <button
                phx-click="select-relative"
                value="parent"
                style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
              >
                Go to Parent
              </button>
              <button
                phx-click="select-relative"
                value="first_sibling"
                style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
              >
                First Sibling
              </button>
              <button
                phx-click="select-relative"
                value="prev_sibling"
                style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
              >
                Prev Sibling
              </button>
              <button
                phx-click="select-relative"
                value="first_child"
                style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
              >
                Go to first Child
              </button>
              <button
                phx-click="select-relative"
                value="last_child"
                style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
              >
                Go to last Child
              </button>
              <button
                phx-click="select-relative"
                value="next_sibling"
                style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
              >
                Next Sibling
              </button>
              <button
                phx-click="select-relative"
                value="last_sibling"
                style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
              >
                Last Sibling
              </button>
            </div>

            <div style="padding: 1ex 0; display: flex; gap: 1ex">
              <button
                phx-click="move-relative"
                value="before_parent"
                style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
              >
                Move before parent
              </button>
              <button
                phx-click="move-relative"
                value="after_parent"
                style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
              >
                Move after parent
              </button>
              <button
                phx-click="move-relative"
                value="into_prev"
                style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
              >
                Indent
              </button>
              <button
                phx-click="move-relative"
                value="backwards"
                style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
              >
                Move backwards
              </button>
              <button
                phx-click="move-relative"
                value="frontwards"
                style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
              >
                Move frontwards
              </button>
              <button
                phx-click="move-relative"
                value="to_front"
                style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
              >
                Move to back
              </button>
              <button
                phx-click="move-relative"
                value="to_back"
                style="cursor: pointer; padding: 1ex; border: none; background: #33a; color: #fff"
              >
                Move to front
              </button>
            </div>
          <% end %>

          <div style="width: 45vw;">
            <.live_component
              id="hierarchy-list"
              module={RenewCollabWeb.HierarchyListComponent}
              socket_schemas={@socket_schemas}
              document={@document}
              symbols={@symbols}
              selection={@selection}
            />
          </div>
        <% end %>

        <h2 style="cursor: pointer;" phx-click="toggle-snapshots">
          <span>{if(@show_snapshots, do: "▼", else: "►")}</span> Snapshots
        </h2>

        <%= if @show_snapshots do %>
          <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: snapshots} <- @snapshots do %>
            <.live_component
              id="snapshot-list"
              module={RenewCollabWeb.SnapshotListComponent}
              snapshots={snapshots}
            />
            <% else _ -> %>
              <p>Loading</p>
          <% end %>
        <% end %>

        <h2 style="cursor: pointer;" phx-click="toggle-health">
          <span>{if(@show_health, do: "▼", else: "►")}</span> Health
        </h2>

        <%= if @show_health do %>
          <div style="width: 45vw;">
            <dl style="display: grid; grid-template-columns: auto auto; justify-content: start; gap: 1ex 1em">
              <dt style="margin: 0">Missing Parenthoods</dt>

              <dd style="margin: 0">
                <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: hierachy_missing} <- @hierachy_missing do %>
                  <details>
                    <summary style="cursor: pointer">{Enum.count(hierachy_missing)}</summary>

                    <ul>
                      <%= for i <- hierachy_missing do %>
                        <li>{i.ancestor_id}/{i.descendant_id}/{i.depth}</li>
                      <% end %>
                    </ul>
                  </details>
                  <% else _ -> %>
                    Loading
                <% end %>
              </dd>

              <dt style="margin: 0">Invalid Parenthoods</dt>

              <dd style="margin: 0">
                <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: hierachy_invalid} <- @hierachy_invalid do %>
                  <details>
                    <summary style="cursor: pointer">{Enum.count(hierachy_invalid)}</summary>

                    <ul>
                      <%= for id <- hierachy_invalid do %>
                        <li>{id}</li>
                      <% end %>
                    </ul>
                  </details>
                  <% else _ -> %>
                    Loading
                <% end %>
              </dd>

              <dt></dt>

              <dd style="margin: 0">
                <button
                  type="button"
                  phx-click="repair_hierarchy"
                  style="cursor: pointer; padding: 1ex; border: none; background: #333; color: #fff"
                >
                  Repair
                </button>
              </dd>
            </dl>
          </div>
        <% end %>

        <h2 style="cursor: pointer;" phx-click="toggle-simulations">
          <span>{if(@show_simulations, do: "▼", else: "►")}</span> Simulations
        </h2>

        <%= if @show_simulations do %>
          <%= with %Phoenix.LiveView.AsyncResult{ok?: true, result: simulation_links} <- @simulation_links do %>
            <%= if Enum.count(simulation_links)> 0 do %>
              <ul style="list-style: none; padding: 0; margin: 0">
                <%= for lnk <- simulation_links do %>
                  <li style={"opacity: #{if(lnk.snapshot_id == @document.current_snaptshot.id, do: 1, else: 0.5)}"}>
                    <%= if lnk.simulation do %>
                      <.link navigate={~p"/simulation/#{lnk.simulation_id}"}>
                        <RenewCollabWeb.RenewComponents.timestamp value={lnk.inserted_at} /> <br />
                        <small>{lnk.simulation_id}</small>
                      </.link>
                    <% else %>
                      <RenewCollabWeb.RenewComponents.timestamp value={lnk.inserted_at} /> <br />
                      <small>{lnk.simulation_id}</small>
                    <% end %>
                  </li>
                <% end %>
              </ul>
            <% end %>
          <% end %>

          <form phx-submit="simulate">
            <input type="hidden" name="redirect" value="no" />
            <label style="display: grid; grid-template-columns: 6em;">
              <button
                type="submit"
                phx-disable-with="Compiling..."
                style="grid-area: 1/1/-1/-1;cursor: pointer; padding: 1ex; border: none; background: #a3a; color: #fff"
              >
                Simulate
              </button>
              <select
                onchange="this.previousElementSibling.click()"
                name="formalism"
                style="cursor: pointer; grid-area: 1/1/-1/-1;opacity: 0; justify-self: stretch; align-self: stretch; "
              >
                <option selected>---cancel---</option>

                <%= for f <- RenewCollabSim.Compiler.SnsCompiler.formalisms() do %>
                  <option>{f}</option>
                <% end %>
              </select>
            </label>
          </form>
        <% end %>
      </div>
    </div>
    """
  end

  defp viewbox(document) do
    RenewCollab.ViewBox.calculate(document)
  end

  def viewbox_center(viewbox) do
    RenewCollab.ViewBox.center(viewbox)
  end

  defp error_to_string(:too_large), do: "The selected file is too large."
  defp error_to_string(:too_many_files), do: "You have selected too many files."

  defp error_to_string(:not_accepted),
    do: "You have selected an unsupported file format. (only .rnw files can be imported)"

  def handle_event("validate-import", params, socket) do
    {:noreply, assign(socket, import_form: to_form(params))}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :import_file, ref)}
  end

  def handle_event("import_document", _params, socket) do
    [command] =
      consume_uploaded_entries(socket, :import_file, fn %{path: path}, %{client_name: filename} ->
        {:ok, content} = File.read(path)

        %Actions.DocumentEditImportFile{
          document_id: socket.assigns.document.id,
          file_name: filename,
          x: 0,
          y: 0,
          file_content: content
        }
      end)

    command
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply,
     socket
     |> assign(:auto_adjust_viewbox, true)}
  end

  def handle_event("toggle_visible", %{"id" => layer_id}, socket) do
    %Actions.DocumentEditSetLayerVisibility{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      visible: :toggle
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event("remove_thumbnail", %{}, socket) do
    %Actions.DocumentEditRemoveThumbnail{
      document_id: socket.assigns.document.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event("make_thumbnail", %{"id" => layer_id}, socket) do
    %Actions.DocumentEditSetThumbnail{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event("toggle-hierarchy", %{}, socket) do
    {:noreply, socket |> update(:show_hierarchy, &(not &1))}
  end

  def handle_event("toggle-selected", %{}, socket) do
    {:noreply, socket |> update(:show_selected, &(not &1))}
  end

  def handle_event("toggle-snapshots", %{}, socket) do
    {:noreply, socket |> update(:show_snapshots, &(not &1))}
  end

  def handle_event("toggle-meta", %{}, socket) do
    {:noreply, socket |> update(:show_meta, &(not &1))}
  end

  def handle_event("toggle-grid", %{}, socket) do
    {:noreply, socket |> update(:show_grid, &(not &1))}
  end

  def handle_event("toggle-health", %{}, socket) do
    {:noreply, socket |> update(:show_health, &(not &1))}
  end

  def handle_event("toggle-simulations", %{}, socket) do
    {:noreply, socket |> update(:show_simulations, &(not &1))}
  end

  def handle_event("update-viewbox", %{}, socket) do
    {:noreply,
     socket
     |> assign(:viewbox, viewbox(socket.assigns.document))}
  end

  def handle_event("make-space", %{}, socket) do
    %Actions.DocumentEditMakeSpaceBetween{
      document_id: socket.assigns.document.id,
      base: {20, 0},
      direction: {100, 0}
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event("detach-bond", %{"id" => bond_id}, socket) do
    %Actions.DocumentEditDeleteBond{
      document_id: socket.assigns.document.id,
      bond_id: bond_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event("repair_hierarchy", %{}, socket) do
    document_id = socket.assigns.document.id
    RenewCollab.Hierarchy.repair_parenthood(document_id)

    {:noreply,
     socket
     |> assign_async(
       [
         :hierachy_missing,
         :hierachy_invalid
       ],
       fn ->
         {:ok,
          %{
            hierachy_missing: RenewCollab.Hierarchy.find_missing(document_id),
            hierachy_invalid: RenewCollab.Hierarchy.find_invalids(document_id)
          }}
       end
     )}
  end

  def handle_event("select_layer", %{"id" => ""}, socket) do
    {:noreply,
     socket
     |> assign(:selection, nil)}
  end

  def handle_event("select_layer", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:selection, id)}
  end

  def handle_event(
        "update_style",
        %{
          "layer_id" => layer_id,
          "element" => "layer",
          "style" => style_attr,
          "value" => value
        },
        socket
      ) do
    %Actions.DocumentEditLayerStyle{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_style",
        %{
          "layer_id" => layer_id,
          "element" => "edge",
          "style" => style_attr,
          "value" => value
        },
        socket
      ) do
    %Actions.DocumentEditLayerEdgeStyle{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_style",
        %{
          "layer_id" => layer_id,
          "element" => "text",
          "style" => style_attr,
          "value" => value
        },
        socket
      ) do
    %Actions.DocumentEditLayerTextStyle{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      style_attr: style_attr,
      value: value
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_text_size_hint",
        %{
          "layer_id" => layer_id,
          "box" => box
        },
        socket
      ) do
    %Actions.DocumentEditLayerTextSizeHint{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      box: box
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event("update_text_body", %{"layer_id" => layer_id, "value" => new_body}, socket) do
    %Actions.DocumentEditLayerTextBody{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_body: new_body
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_box_size",
        %{
          "layer_id" => layer_id,
          "value" => new_size
        },
        socket
      ) do
    %Actions.DocumentEditLayerBoxSize{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_size: new_size
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_text_position",
        %{
          "layer_id" => layer_id,
          "value" =>
            %{
              "position_x" => _position_x,
              "position_y" => _position_y
            } = new_position
        },
        socket
      ) do
    %Actions.DocumentEditLayerTextPosition{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_position: new_position
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_edge_position",
        %{
          "layer_id" => layer_id,
          "value" => new_position
        },
        socket
      ) do
    %Actions.DocumentEditLayerEdgePosition{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_position: new_position
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_edge_flip",
        %{
          "id" => layer_id
        },
        socket
      ) do
    %Actions.DocumentEditLayerEdgeSwapDirection{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_waypoint_position",
        %{
          "layer_id" => layer_id,
          "waypoint_id" => waypoint_id,
          "value" =>
            %{
              "position_x" => _position_x,
              "position_y" => _position_y
            } = new_position
        },
        socket
      ) do
    %Actions.DocumentEditLayerEdgeWaypointPosition{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      waypoint_id: waypoint_id,
      new_position: new_position
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "delete_waypoint",
        %{
          "layer_id" => layer_id,
          "waypoint_id" => waypoint_id
        },
        socket
      ) do
    %Actions.DocumentEditDeleteEdgeWaypoint{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      waypoint_id: waypoint_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_waypoint",
        %{
          "layer_id" => layer_id,
          "after_waypoint_id" => prev_waypoint_id,
          "position_x" => position_x,
          "position_y" => position_y
        },
        socket
      ) do
    %Actions.DocumentEditCreateEdgeWaypoint{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id,
      position: {position_x, position_y}
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_waypoint",
        %{
          "layer_id" => layer_id,
          "after_waypoint_id" => prev_waypoint_id
        },
        socket
      ) do
    %Actions.DocumentEditCreateEdgeWaypoint{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      prev_waypoint_id: prev_waypoint_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "clear_waypoints",
        %{
          "layer_id" => layer_id
        },
        socket
      ) do
    %Actions.DocumentEditEdgeRemoveAllWaypoints{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_semantic_tag",
        %{
          "layer_id" => layer_id,
          "value" => new_tag
        },
        socket
      ) do
    %Actions.DocumentEditLayerSemanticTag{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      new_tag: new_tag
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_shape",
        %{
          "layer_id" => layer_id,
          "value" => %{"shape_id" => shape_id, "shape_attributes" => shape_attributes}
        },
        socket
      ) do
    %Actions.DocumentEditLayerBoxShape{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      shape_id: shape_id,
      attributes: shape_attributes
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "move_layer",
        %{
          "layer_id" => layer_id,
          "target_layer_id" => target_layer_id,
          "order" => order,
          "relative" => relative
        },
        socket
      ) do
    %Actions.DocumentEditReorderLayer{
      document_id: socket.assigns.document.id,
      layer_ids: [layer_id],
      target_layer_id: target_layer_id,
      target: Actions.DocumentEditReorderLayer.parse_hierarchy_position(order, relative)
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "move_layer_relative",
        %{
          "layer_id" => layer_id,
          "dx" => dx,
          "dy" => dy
        },
        socket
      ) do
    %Actions.DocumentEditMoveLayerRelative{
      document_id: socket.assigns.document.id,
      layer_ids: [layer_id],
      dx: dx,
      dy: dy
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "delete_layer",
        %{"id" => layer_id},
        socket
      ) do
    %Actions.DocumentEditDeleteLayer{
      document_id: socket.assigns.document.id,
      layer_ids: [layer_id],
      delete_children: true
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket |> assign(:selection, nil)}
  end

  def handle_event(
        "create_group",
        %{"example" => "yes"},
        socket
      ) do
    %Actions.DocumentEditCreateLayer{
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.GroupFigure"
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "wrap_in_group",
        %{"layer_id" => layer_id},
        socket
      ) do
    %Actions.DocumentEditCreateParentLayer{
      document_id: socket.assigns.document.id,
      child_layer_id: layer_id,
      attrs: %{}
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_text",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} = viewbox_center(socket.assigns.viewbox)

    %Actions.DocumentEditCreateLayer{
      base_layer_id: socket.assigns.selection,
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "de.renew.gui.CPNTextFigure",
        "text" => %{
          "position_x" => cx,
          "position_y" => cy,
          "body" => "Hello World"
        }
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_linked_text",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} =
      Enum.find(socket.assigns.document.layers, &(&1.id == socket.assigns.selection))
      |> case do
        %{box: %{position_x: x, position_y: y, width: width, height: height}} ->
          {x + width / 2, y + height / 2}

        %{edge: %{source_x: source_x, source_y: source_y, target_x: target_x, target_y: target_y}} ->
          {(source_x + target_x) / 2, (source_y + target_y) / 2}
      end

    %Actions.DocumentEditCreateLayer{
      base_layer_id: socket.assigns.selection,
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "de.renew.gui.CPNTextFigure",
        "text" => %{
          "position_x" => cx,
          "position_y" => cy,
          "body" => "[]"
        },
        "outgoing_link" => %{
          "target_layer_id" => socket.assigns.selection
        }
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_box",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} = viewbox_center(socket.assigns.viewbox)

    %Actions.DocumentEditCreateLayer{
      base_layer_id: socket.assigns.selection,
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.RectangleFigure",
        "box" => %{
          "position_x" => cx - 100,
          "position_y" => cy - 50,
          "width" => 200,
          "height" => 100
        }
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_edge",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} = viewbox_center(socket.assigns.viewbox)

    %Actions.DocumentEditCreateLayer{
      base_layer_id: socket.assigns.selection,
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.PolyLineFigure",
        "edge" => %{
          "source_x" => cx - 100,
          "source_y" => cy - 50,
          "target_x" => cx + 100,
          "target_y" => cy + 50
        }
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_transition",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} = viewbox_center(socket.assigns.viewbox)

    %Actions.DocumentEditCreateLayer{
      base_layer_id: socket.assigns.selection,
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "de.renew.gui.TransitionFigure",
        "box" => %{
          "position_x" => cx - 12,
          "position_y" => cy - 8,
          "width" => 24,
          "height" => 16
        },
        "interface" => %{
          "socket_schema_id" => "4FDF577B-DB81-462E-971E-FA842F0ABA1E"
        }
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_place",
        %{"example" => "yes"},
        socket
      ) do
    {cx, cy} = viewbox_center(socket.assigns.viewbox)

    %Actions.DocumentEditCreateLayer{
      base_layer_id: socket.assigns.selection,
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "de.renew.gui.PlaceFigure",
        "box" => %{
          "position_x" => cx - 10,
          "position_y" => cy - 10,
          "width" => 20,
          "height" => 20,
          "symbol_shape_id" => "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42"
        },
        "interface" => %{
          "socket_schema_id" => "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC"
        }
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_edge",
        %{} = edge,
        socket
      ) do
    %Actions.DocumentEditCreateLayer{
      base_layer_id: socket.assigns.selection,
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "de.renew.gui.ArcConnection",
        "edge" =>
          edge
          |> Map.put_new("style", %{})
          |> put_in(
            ["style", "target_tip_symbol_shape_id"],
            "84DC6617-D555-4BAB-BA33-04A5FA442F00"
          )
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_edge_bond",
        %{
          "edge_id" => edge_id,
          "kind" => kind,
          "layer_id" => layer_id,
          "socket_id" => socket_id
        },
        socket
      ) do
    %Actions.DocumentEditCreateEdgeBond{
      document_id: socket.assigns.document.id,
      edge_id: edge_id,
      kind: kind,
      layer_id: layer_id,
      socket_id: socket_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_grid_edge",
        %{
          "source_layer_id" => source_layer_id,
          "source_socket_id" => source_socket_id,
          "target_layer_id" => target_layer_id,
          "target_socket_id" => target_socket_id
        },
        socket
      ) do
    %Actions.DocumentEditCreateLayer{
      base_layer_id: socket.assigns.selection,
      document_id: socket.assigns.document.id,
      attrs: %{
        "semantic_tag" => "CH.ifa.draw.figures.PolyLineFigure",
        "edge" => %{
          "source_x" => 0,
          "source_y" => 0,
          "target_x" => 0,
          "target_y" => 0,
          "source_bond" => %{
            "layer_id" => source_layer_id,
            "socket_id" => source_socket_id
          },
          "target_bond" => %{
            "layer_id" => target_layer_id,
            "socket_id" => target_socket_id
          }
        }
      }
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "unlink_layer",
        %{
          "id" => layer_id
        },
        socket
      ) do
    %Actions.DocumentEditUnlinkLayer{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "link_layer",
        %{
          "source_layer_id" => layer_id,
          "target_layer_id" => target_layer_id
        },
        socket
      ) do
    %Actions.DocumentEditLinkLayer{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      target_layer_id: target_layer_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "assign_layer_socket_schema",
        %{
          "layer_id" => layer_id,
          "socket_schema_id" => socket_schema_id
        },
        socket
      ) do
    %Actions.DocumentEditLayerAssignSocketSchema{
      document_id: socket.assigns.document.id,
      layer_id: layer_id,
      socket_schema_id: socket_schema_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "remove_layer_socket_schema",
        %{
          "layer_id" => layer_id
        },
        socket
      ) do
    %Actions.DocumentEditRemoveLayerSocketSchema{
      document_id: socket.assigns.document.id,
      layer_id: layer_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_snapshot",
        %{},
        socket
      ) do
    %Actions.DocumentEditCreateSnapshot{
      document_id: socket.assigns.document.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "restore",
        %{"id" => snapshot_id},
        socket
      ) do
    %Actions.DocumentSnapshotRestore{
      document_id: socket.assigns.document.id,
      snapshot_id: snapshot_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "create_snapshot_label",
        %{"snapshot_id" => snapshot_id, "description" => description},
        socket
      ) do
    %Actions.DocumentEditSnapshotCreateLabel{
      document_id: socket.assigns.document.id,
      snapshot_id: snapshot_id,
      description: description
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "remove_snapshot_label",
        %{"id" => snapshot_id},
        socket
      ) do
    %Actions.DocumentEditSnapshotRemoveLabel{
      document_id: socket.assigns.document.id,
      snapshot_id: snapshot_id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "prune_snaphots",
        %{},
        socket
      ) do
    %Actions.DocumentSnapshotsPrune{
      document_id: socket.assigns.document.id
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "update_document_meta",
        meta,
        socket
      ) do
    %Actions.DocumentUpdateMeta{
      document_id: socket.assigns.document.id,
      meta: meta
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)

    {:noreply, socket}
  end

  def handle_event(
        "insert_document",
        %{"document_id" => document_id},
        socket
      ) do
    case document_id do
      "" ->
        nil

      id ->
        %Actions.DocumentEditInsertDocument{
          target_document_id: socket.assigns.document.id,
          source_document_id: id
        }
        |> Dispatcher.perform_as(socket.assigns.current_account)
    end

    {:noreply, socket}
  end

  def handle_event("select-relative", %{"value" => "parent"}, socket) do
    select_relative(socket, :parent)
  end

  def handle_event("select-relative", %{"value" => "first_sibling"}, socket) do
    select_relative(socket, {:sibling, :first})
  end

  def handle_event("select-relative", %{"value" => "prev_sibling"}, socket) do
    select_relative(socket, {:sibling, :prev})
  end

  def handle_event("select-relative", %{"value" => "first_child"}, socket) do
    select_relative(socket, {:child, :first})
  end

  def handle_event("select-relative", %{"value" => "last_child"}, socket) do
    select_relative(socket, {:child, :last})
  end

  def handle_event("select-relative", %{"value" => "next_sibling"}, socket) do
    select_relative(socket, {:sibling, :next})
  end

  def handle_event("select-relative", %{"value" => "last_sibling"}, socket) do
    select_relative(socket, {:sibling, :last})
  end

  def handle_event("move-relative", %{"value" => "before_parent"}, socket) do
    move_relative(socket, :parent, {:below, :outside})
  end

  def handle_event("move-relative", %{"value" => "after_parent"}, socket) do
    move_relative(socket, :parent, {:above, :outside})
  end

  def handle_event("move-relative", %{"value" => "frontwards"}, socket) do
    move_relative(socket, {:sibling, :next}, {:above, :outside})
  end

  def handle_event("move-relative", %{"value" => "backwards"}, socket) do
    move_relative(socket, {:sibling, :prev}, {:below, :outside})
  end

  def handle_event("move-relative", %{"value" => "to_front"}, socket) do
    move_relative(socket, {:sibling, :first}, {:below, :outside})
  end

  def handle_event("move-relative", %{"value" => "to_back"}, socket) do
    move_relative(socket, {:sibling, :last}, {:above, :outside})
  end

  def handle_event("move-relative", %{"value" => "into_prev"}, socket) do
    move_relative(socket, {:sibling, :prev}, {:above, :inside})
  end

  def handle_event("simulate", %{} = params, socket) do
    formalism = RenewCollabSim.Compiler.SnsCompiler.default_formalism()

    %Actions.SimulationCreateFromDocumentsInProject{
      project_id: socket.assigns.document.project_assignment.project_id,
      document_ids: [socket.assigns.document.id],
      formalism: formalism,
      main_net_name:
        RenewCollabSim.Compiler.SnsCompiler.normalize_net_name(socket.assigns.document.name)
    }
    |> Dispatcher.perform_as(socket.assigns.current_account)
    |> case do
      {:ok, %RenewCollabSim.Entities.Simulation{} = sim} ->
        case params do
          %{"redirect" => "no"} ->
            {:noreply, socket |> put_flash(:info, "Simulation created")}

          _ ->
            {:noreply,
             socket
             |> put_flash(:info, "Simulation created")
             |> redirect(to: ~p"/simulation/#{sim.id}")}
        end

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           SimulationError.format(reason, "Failed to create simulation")
         )}
    end
  end

  defp find_relative(socket, rel) do
    %Views.DocumentLayerRelative{
      document_id: socket.assigns.document.id,
      layer_id: socket.assigns.selection,
      id_only: true,
      relative: rel
    }
    |> Fetcher.fetch_as(socket.assigns.current_account)
  end

  defp select_relative(socket, rel) do
    with s when not is_nil(s) <- socket.assigns.selection,
         new_selection when is_binary(new_selection) <- find_relative(socket, rel) do
      {:noreply, socket |> assign(:selection, new_selection)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  defp move_relative(socket, rel, order) do
    with s when not is_nil(s) <- socket.assigns.selection do
      %Actions.DocumentEditReorderLayerRelative{
        document_id: socket.assigns.document.id,
        layer_ids: [socket.assigns.selection],
        relative_direction: rel,
        target: order
      }
      |> Dispatcher.perform_as(socket.assigns.current_account)

      {:noreply, socket}
    else
      _ ->
        {:noreply, socket}
    end
  end
end
