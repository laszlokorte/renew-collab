defmodule RenewCollabWeb.PasswordResetController do
  use RenewCollabWeb, :controller

  alias RenewCollabAuth.Entities.AccountPasswordResetRequest
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions

  action_fallback RenewCollabWeb.FallbackController

  def new(conn, _params) do
    reg = %RenewCollabAuth.Entities.AccountPasswordResetRequest{}

    conn
    |> render(:new, %{
      changeset:
        RenewCollabAuth.Entities.AccountPasswordResetRequest.changeset(
          reg,
          %{}
        )
    })
  end

  def create(conn, %{"account_password_reset_request" => reset_request}) do
    %Actions.AccountRequestPasswordReset{email: Map.get(reset_request, "email")}
    |> Dispatcher.perform_as(nil)
    |> case do
      {:ok, reset} ->
        RenewCollabAuth.Email.Sender.reset_password(
          reset,
          url(~p"/account/reset/#{reset.id}/#{RenewCollabWeb.Token.sign(%{reset_id: reset.id})}")
        )
        |> RenewCollabAuth.Mailer.deliver()

        Task.Supervisor.start_child(RenewCollabAuth.AsyncEmailSupervisor, fn ->
          nil
        end)

        conn
        |> put_flash(:info, "Password Reset link has been sent via E-mail")
        |> redirect(to: ~p"/login")

      {:error, _changeset} ->
        conn
        # Do not expose invalid E-mails
        |> put_flash(:info, "Password Reset link has been sent via E-mail")
        |> redirect(to: ~p"/login")

      _ ->
        conn
        # Do not expose invalid E-mails
        |> put_flash(:error, "Unexpected Error")
        |> redirect(to: ~p"/login")
    end
  end

  def reset_password(conn, %{
        "reset_id" => reset_id,
        "confirmation_code" => confirmation_code,
        "account" => account
      }) do
    %Views.PendingPasswordResetRequest{reset_id: reset_id}
    |> Fetcher.fetch_as(nil)
    |> case do
      nil ->
        conn
        |> put_flash(:error, "not found")
        |> redirect(to: ~p"/signup")

      %AccountPasswordResetRequest{} = reset ->
        if verify(confirmation_code, reset) do
          %Actions.AccountResetPasswordAsUser{
            reset_id: reset.id,
            account: account
          }
          |> Dispatcher.perform_as(nil)
          |> case do
            :ok ->
              conn
              |> put_flash(:info, "Password has been reset sucessfuly.")
              |> redirect(to: ~p"/login")

            {:error, changeset} ->
              conn
              |> render(:reset, %{
                reset: reset,
                code: confirmation_code,
                changeset: changeset
              })

            _ ->
              conn
              |> put_flash(:error, "Unexpected Error")
              |> render(:reset, %{
                reset: reset,
                code: confirmation_code,
                changeset:
                  RenewCollabAuth.Entities.Account.changeset(
                    %RenewCollabAuth.Entities.Account{},
                    %{}
                  )
              })
          end
        else
          conn
          |> put_flash(:error, "Invalid Confirmation code")
          |> redirect(to: ~p"/signup")
        end
    end
  end

  def confirm(conn, %{
        "reset_id" => reset_id,
        "confirmation_code" => confirmation_code
      }) do
    %Views.PendingPasswordResetRequest{reset_id: reset_id}
    |> Fetcher.fetch_as(nil)
    |> case do
      nil ->
        conn
        |> put_flash(:error, "not found")
        |> redirect(to: ~p"/signup")

      %AccountPasswordResetRequest{} = reset ->
        if verify(confirmation_code, reset) do
          conn
          |> render(:reset, %{
            reset: reset,
            code: confirmation_code,
            changeset:
              RenewCollabAuth.Entities.Account.changeset(
                %RenewCollabAuth.Entities.Account{},
                %{}
              )
          })
        else
          conn
          |> put_flash(:error, "Invalid Confirmation code")
          |> redirect(to: ~p"/account/reset")
        end
    end
  end

  defp verify(token, %AccountPasswordResetRequest{id: reg_id}) do
    RenewCollabWeb.Token.verify(token)
    |> case do
      {:ok, %{reset_id: ^reg_id}} ->
        true

      _ ->
        false
    end
  end
end
