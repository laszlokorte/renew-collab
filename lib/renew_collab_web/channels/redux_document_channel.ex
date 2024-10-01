defmodule RenewCollabWeb.ReduxDocumentChannel do
  use LiveState.Channel, web_module: RenewCollabWeb

  # Phoenix.PubSub.broadcast(
  #         LiveStateComments.PubSub,
  #         "comments:#{comment.url}",
  #         {:comment_created, comment}
  #       )

  @impl true
  def init("redux_document:" <> documet_id, _params, _socket) do
    case RenewCollab.Renew.get_document_with_elements(documet_id) do
      nil ->
        {:error, %{reason: "not found"}}

      doc ->
        Phoenix.PubSub.subscribe(RenewCollab.PubSub, "document:#{documet_id}")

        {:ok,
         %{
           document:
             RenewCollabWeb.DocumentJSON.show(%{
               document: doc
             })
         }}
    end
  end

  @impl true
  def handle_message({:document_changed, document_id}, state) do
    {:noreply,
     state
     |> Map.put(
       :document,
       RenewCollabWeb.DocumentJSON.show(%{
         document: RenewCollab.Renew.get_document_with_elements(document_id)
       })
     )}
  end
end
