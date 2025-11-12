defmodule RenewCollabAuth.Email.Sender do
  alias RenewCollabAuth.Entities.Registration
  use Phoenix.Swoosh, view: RenewCollabAuth.Email.View

  def confirm(%Registration{} = reg, confirm_url) do
    new()
    |> to(reg.email)
    |> from({"Petristation", "petristation@mail.petristation.net"})
    |> subject("Petristation: Confirm your E-mail address")
    |> render_body(:confirm, %{reg: reg, confirm_url: confirm_url})
  end
end
