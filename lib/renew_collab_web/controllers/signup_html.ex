defmodule RenewCollabWeb.SignupHTML do
  use RenewCollabWeb, :html

  embed_templates "signup_html/*"

  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  def signup_form(assigns)
end
