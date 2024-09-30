defmodule RenewCollabWeb.LoginHTML do
  use RenewCollabWeb, :html

  embed_templates "login_html/*"

  @doc """
  Renders a account form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  def login_form(assigns)
end
