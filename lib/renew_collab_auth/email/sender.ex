defmodule RenewCollabAuth.Email.Sender do
  alias RenewCollabAuth.Entities.AccountPasswordResetRequest
  alias RenewCollabAuth.Entities.Registration

  use Phoenix.Swoosh,
    view: RenewCollabAuth.Email.EmailView,
    layout: {RenewCollabAuth.Email.LayoutView, :email}

  def confirm(%Registration{} = reg, confirm_url) do
    conf = Application.fetch_env!(:renew_collab, RenewCollabAuth.Email.Sender)

    new()
    |> to(reg.email)
    |> from({Keyword.get(conf, :sender_name), Keyword.get(conf, :sender_email)})
    |> subject("#{Keyword.get(conf, :subject_prefix)}: Confirm your E-mail address")
    |> render_body(:confirm, %{reg: reg, confirm_url: confirm_url})
  end

  def reset_password(%AccountPasswordResetRequest{} = reset, confirm_url) do
    conf = Application.fetch_env!(:renew_collab, RenewCollabAuth.Email.Sender)

    new()
    |> to(reset.account.email)
    |> from({Keyword.get(conf, :sender_name), Keyword.get(conf, :sender_email)})
    |> subject("#{Keyword.get(conf, :subject_prefix)}: Reset your password")
    |> render_body(:reset, %{reg: reset, confirm_url: confirm_url})
  end
end
