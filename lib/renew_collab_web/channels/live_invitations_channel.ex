defmodule RenewCollabWeb.LiveInvitationsChannel do
  use RenewCollabWeb.StateChannel, web_module: RenewCollabWeb

  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  @impl true
  def init("my-invitations", _params, socket) do
    account_id = socket.assigns.current_account.id
    username = socket.assigns.current_account.username
    connection_id = socket.assigns.connection_id

    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "pub-my-invitations:#{account_id}")

    {:ok, load_state(socket.assigns.current_account),
     %{:account => socket.assigns.current_account}}
  end

  @impl true
  def handle_message(:invitations_changed, _state, %{
        :account => account
      }) do
    {:noreply, load_state(account)}
  end

  defp load_state(current_account) do
    %Views.MyProjectInvitations{
      account_id: current_account.id
    }
    |> Fetcher.fetch_as(current_account)
    |> then(&%{invitations: &1})
    |> RenewCollabWeb.InvitationJSON.index_content()
  end

  @impl true
  def handle_event(
        "accept",
        %{"project_id" => project_id, "invitation_id" => invitation_id},
        _state,
        %{
          account: account
        }
      ) do
    %Actions.ProjectAcceptInvitation{
      invitation_id: invitation_id,
      project_id: project_id
    }
    |> Dispatcher.perform_as(account)

    :ack
  end

  @impl true
  def handle_event(
        "reject",
        %{"project_id" => project_id},
        _state,
        %{
          account: account
        }
      ) do
    %Actions.ProjectRejectInvitation{
      account_id: account.id,
      project_id: project_id
    }
    |> Dispatcher.perform_as(account)

    :ack
  end

  defp make_color(account_id) do
    hue =
      <<i <- account_id |> then(&:crypto.hash(:md5, &1))>> |> for(do: i) |> Enum.sum() |> rem(360)

    "hsl(#{hue}, 70%, 40%)"
  end
end
