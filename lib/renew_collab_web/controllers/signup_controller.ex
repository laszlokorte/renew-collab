defmodule RenewCollabWeb.SignupController do
  use RenewCollabWeb, :controller

  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions.RegistrationCreateAsUser
  alias RenewCollabAuth.Entities.Registration

  action_fallback RenewCollabWeb.FallbackController

  def new(conn, _params) do
    conn
    |> render(:new, %{
      changeset:
        RenewCollabAuth.Entities.Registration.changeset(
          %RenewCollabAuth.Entities.Registration{},
          %{}
        )
    })
  end

  def create(conn, %{"registration" => registration}) do
    %RegistrationCreateAsUser{email: Map.get(registration, "email")}
    |> Dispatcher.perform_as(nil)
    |> case do
      {:ok, reg} ->
        conn
        |> put_flash(:info, "Signup almost complete")
        |> redirect(to: ~p"/signup/#{reg.id}")

      {:error, changeset} ->
        conn
        |> render(:new, %{
          changeset: changeset
        })
    end

    #  |> render(:new, %{
    #    changeset:
    #      RenewCollabAuth.Entities.Account.changeset(
    #        %RenewCollabAuth.Entities.Account{},
    #        %{}
    #      )
    #  })
  end

  def set_password(conn, %{
        "registration_id" => registration_id,
        "confirmation_code" => confirmation_code,
        "account" => %{
          "password" => password,
          "password_repeat" => password_repeat
        }
      }) do
    registration = %Registration{id: registration_id}

    conn
    |> put_flash(:info, "Signup complete")
    |> redirect(to: ~p"/login")
  end

  def confirm(conn, %{
        "registration_id" => registration_id,
        "confirmation_code" => confirmation_code
      }) do
    registration = %Registration{id: registration_id}

    conn
    |> render(:confirm, %{
      registration: registration,
      code: confirmation_code,
      changeset:
        RenewCollabAuth.Entities.Account.changeset(
          %RenewCollabAuth.Entities.Account{},
          %{}
        )
    })
  end

  def waiting(conn, %{"registration_id" => registration_id}) do
    registration = %Registration{id: registration_id}

    conn
    |> render(:waiting, %{
      registration: registration
    })
  end
end
