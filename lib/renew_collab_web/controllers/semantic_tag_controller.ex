defmodule RenewCollabWeb.SemanticTagController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  @grammar Renewex.Grammar.new(11)

  def index(conn, _params) do
    render(conn, :index,
      semantic_tags:
        for {class_name, _} <- @grammar.hierarchy do
          class_name
        end
    )
  end

  def rules(conn, _params) do
    render(conn, :rules, %{})
  end
end
