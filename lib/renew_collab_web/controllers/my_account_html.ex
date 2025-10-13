defmodule RenewCollabWeb.MyAccountHTML do
  use RenewCollabWeb, :html

  embed_templates "my_account_html/*"

  @doc """
  Renders a account form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  def change_password_form(assigns)
end
