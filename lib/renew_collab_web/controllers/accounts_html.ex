defmodule RenewCollabWeb.AccountsHTML do
  use RenewCollabWeb, :html

  embed_templates "accounts_html/*"

  @doc """
  Renders a account form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def account_form(assigns)
end
