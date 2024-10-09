defmodule RenewCollabWeb.ReduxDocumentsChannel do
  use LiveState.Channel, web_module: RenewCollabWeb

  @impl true
  def init("redux_documents", _params, _socket) do
    Phoenix.PubSub.subscribe(RenewCollab.PubSub, "documents")

    {:ok, RenewCollabWeb.DocumentJSON.index(%{documents: RenewCollab.Renew.list_documents()})}
  end

  @impl true
  def handle_message(:any, state) do
    {:noreply,
     RenewCollabWeb.DocumentJSON.index(%{documents: RenewCollab.Renew.list_documents()})}
  end
end
