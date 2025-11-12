defmodule RenewCollabWeb.SignupController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabAuth.Entities.Registration

  action_fallback RenewCollabWeb.FallbackController

  def new(conn, _params) do
    reg = %RenewCollabAuth.Entities.Registration{}

    conn
    |> render(:new, %{
      changeset:
        RenewCollabAuth.Entities.Registration.changeset(
          reg,
          %{}
        )
    })
  end

  def create(conn, %{"registration" => registration}) do
    %Actions.RegistrationCreateAsUser{email: Map.get(registration, "email")}
    |> Dispatcher.perform_as(nil)
    |> case do
      {:ok, reg} ->
        Task.Supervisor.start_child(RenewCollabAuth.AsyncEmailSupervisor, fn ->
          RenewCollabAuth.Email.Sender.confirm(
            reg,
            url(~p"/signup/#{reg.id}/#{RenewCollabWeb.Token.sign(%{registration_id: reg.id})}")
          )
          |> RenewCollabAuth.Mailer.deliver()
        end)

        conn
        |> put_flash(:info, "Signup in progress")
        |> redirect(to: ~p"/signup/#{reg.id}")

      {:error, changeset} ->
        conn
        |> render(:new, %{
          changeset: changeset
        })
    end
  end

  def set_password(conn, %{
        "registration_id" => registration_id,
        "confirmation_code" => confirmation_code,
        "account" => account
      }) do
    %Views.MyRegistration{registration_id: registration_id}
    |> Fetcher.fetch_as(nil)
    |> case do
      nil ->
        conn
        |> put_flash(:error, "not found")
        |> redirect(to: ~p"/signup")

      %Registration{} = reg ->
        if verify(confirmation_code, reg) do
          %Actions.RegistrationConfirmAsUser{
            registration_id: registration_id,
            account: account
          }
          |> Dispatcher.perform_as(nil)
          |> case do
            :ok ->
              conn
              |> put_flash(:info, "Signup successful")
              |> redirect(to: ~p"/login")

            {:error, changeset} ->
              conn
              |> render(:confirm, %{
                registration: reg,
                code: confirmation_code,
                changeset: changeset
              })
          end
        else
          conn
          |> put_flash(:error, "Invalid Confirmation code")
          |> redirect(to: ~p"/signup/#{reg.id}")
        end
    end
  end

  def confirm(conn, %{
        "registration_id" => registration_id,
        "confirmation_code" => confirmation_code
      }) do
    %Views.MyRegistration{registration_id: registration_id}
    |> Fetcher.fetch_as(nil)
    |> case do
      nil ->
        conn
        |> put_flash(:error, "not found")
        |> redirect(to: ~p"/signup")

      %Registration{} = reg ->
        if verify(confirmation_code, reg) do
          conn
          |> render(:confirm, %{
            registration: reg,
            code: confirmation_code,
            changeset:
              RenewCollabAuth.Entities.Account.changeset(
                %RenewCollabAuth.Entities.Account{email: reg.email},
                %{}
              )
          })
        else
          conn
          |> put_flash(:error, "Invalid Confirmation code")
          |> redirect(to: ~p"/signup/#{reg.id}")
        end
    end
  end

  def waiting(conn, %{"registration_id" => registration_id}) do
    %Views.MyRegistration{registration_id: registration_id}
    |> Fetcher.fetch_as(nil)
    |> case do
      nil ->
        conn
        |> put_flash(:error, "not found")
        |> redirect(to: ~p"/signup")

      %Registration{} = reg ->
        conn
        |> render(:waiting, %{
          registration: reg
        })
    end
  end

  defp verify(token, %Registration{id: reg_id}) do
    RenewCollabWeb.Token.verify(token)
    |> case do
      {:ok, %{registration_id: ^reg_id}} -> :ok
      _ -> false
    end
  end
end
