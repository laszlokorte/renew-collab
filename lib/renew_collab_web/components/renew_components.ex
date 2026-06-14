defmodule RenewCollabWeb.RenewComponents do
  use Phoenix.Component
  use RenewCollabWeb, :verified_routes

  alias Phoenix.LiveView.JS

  defp app_titel() do
    Application.get_env(:renew_collab, :app_titel)
  end

  defp editor_url() do
    Application.get_env(:renew_collab, :editor_url)
  end

  attr :value, :map
  attr :format, :string, default: "%Y-%m-%d %H:%M"

  def timestamp(assigns) do
    ~H"""
    <time datetime={Calendar.strftime(@value, "%Y-%m-%d %H:%M")}>
      {Calendar.strftime(@value, @format)}
    </time>
    """
  end

  attr :blank, :boolean, default: false
  attr :logout, :boolean, default: false
  attr :tab, :atom, default: nil
  attr :project_id, :string, default: nil
  attr :flash, :map, default: nil

  def app_header(assigns) do
    assigns = assigns |> assign(:editor_url, editor_url())

    ~H"""
    <div style="position: fixed; top: 0; left: 0; right: 0; height: 3em; display: grid; grid-template: [stack-start] 1fr [stack-end] / [stack-start] 1fr [stack-end];">
      <div style="grid-area: stack;z-index: 10;pointer-events: none; align-self: center; justify-self: center;">
        <.flash_group flash={@flash || nil} />
      </div>
      
      <header style="grid-area: stack; background: #333; color: #fff; padding: 1em; display: flex; justify-content: space-between; font-family: monospace;">
        <.link style="color: white; align-self: center; text-decoration: none" navigate={~p"/"}>
          <h1 style="margin: 0; font-size: 1.3em; display: flex; align-items: center; gap: 1ex">
            <img src="/favicon.svg" style="width: 1.5em; height: 1.5em" /> {app_titel()}
          </h1>
        </.link>
        <div style="display: flex; gap: 1.5em; align-items: stretch;align-self: stretch;">
          <%= if not @blank do %>
            <%= if @project_id do %>
              <.link
                style={"padding: 0.5ex 1ex; align-self: stretch; color: white; align-self: center;#{if(@tab==:documents, do: "text-decoration: none; color: black; background: white")}"}
                navigate={~p"/project/#{@project_id}/documents"}
              >
                Documents
              </.link>
              <.link
                style={"padding: 0.5ex 1ex; align-self: stretch; color: white; align-self: center;#{if(@tab==:simulations, do: "text-decoration: none; color: black; background: white")}"}
                navigate={~p"/project/#{@project_id}/simulations"}
              >
                Simulations
              </.link>
              <.link
                style={"padding: 0.5ex 1ex; align-self: stretch; color: white; align-self: center;#{if(@tab==:sns, do: "text-decoration: none; color: black; background: white")}"}
                navigate={~p"/project/#{@project_id}/shadow_nets"}
              >
                Shadow Nets
              </.link>
              <.link
                style={"padding: 0.5ex 1ex; align-self: stretch; color: white; align-self: center;#{if(@tab==:settings, do: "text-decoration: none; color: black; background: white")}"}
                navigate={~p"/project/#{@project_id}/settings"}
              >
                Settings
              </.link>
            <% end %>
          <% end %>
          
          <%= if @logout do %>
            <.link style="color: white; align-self: center;" href={~p"/logout"} method="delete">
              Log out
            </.link>
          <% end %>
          
          <%= if @editor_url do %>
            <div style="display: flex; gap: 2em; align-items: stretch; margin-left: auto; margin-right: 1em">
              <.link
                target="_blank"
                style="text-decoration-color: #7fdfa4aa; outline: 2px solid #7fdfa4aa; color: white; align-self: center; padding: 0.7ex; background: #23875d; border-radius: 0.3ex"
                href={@editor_url}
              >
                Go to Editor
              </.link>
            </div>
          <% end %>
        </div>
      </header>
    </div>
     <hr style="margin: 0 0 3em 0; height: 0; border: none; display: block; clear: both;" />
    """
  end

  attr :document, :map, required: true
  attr :filter, :atom, default: nil
  slot :item, required: true

  def layers(assigns) do
    ~H"""
    <%= for layer <- @document.layers, layer.direct_parent_hood == nil and of_type(@filter, layer) do %>
      {render_slot(@item, layer)}
      <.child_layers document={@document} parent_id={layer.id} filter={@filter}>
        <:item :let={child_layer}>{render_slot(@item, child_layer)}</:item>
      </.child_layers>
    <% end %>
    """
  end

  attr :document, :map, required: true
  attr :parent_id, :string, required: true
  attr :filter, :atom, default: nil
  slot :item, required: true

  defp child_layers(assigns) do
    ~H"""
    <%= for layer <- @document.layers, layer.direct_parent_hood, layer.direct_parent_hood.ancestor_id == @parent_id and of_type(@filter, layer) do %>
      {render_slot(@item, layer)}
      <.child_layers document={@document} parent_id={layer.id} filter={@filter}>
        <:item :let={child_layer}>{render_slot(@item, child_layer)}</:item>
      </.child_layers>
    <% end %>
    """
  end

  defp of_type(nil, _), do: true
  defp of_type(:box, layer), do: not is_nil(layer.box) or group?(layer)
  defp of_type(:text, layer), do: not is_nil(layer.text) or group?(layer)
  defp of_type(:edge, layer), do: not is_nil(layer.edge) or group?(layer)

  defp group?(layer), do: is_nil(layer.box) and is_nil(layer.text) and is_nil(layer.edge)

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      role="alert"
      class={[
        "flash",
        @kind == :info && "flash-info",
        @kind == :error && "flash-error"
      ]}
      {@rest}
    >
      <div>{msg}</div>
      
      <button
        type="button"
        class="flash-button"
        aria-label="close"
        phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
        style="pointer-events:all"
      >
        Discard
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} class="flash-group">
      <.flash kind={:info} title="Success!" flash={@flash} />
      <.flash kind={:error} title="Error!" flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {"Attempting to reconnect"}
      </.flash>
      
      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {"Hang in there while we get back on track"}
      </.flash>
    </div>
    """
  end

  def show(js \\ %JS{}, selector) do
    js |> JS.remove_attribute("hidden", to: selector)
  end

  def hide(js \\ %JS{}, selector) do
    js |> JS.set_attribute({"hidden", true}, to: selector)
  end
end
