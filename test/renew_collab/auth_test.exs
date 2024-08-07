defmodule RenewCollab.AuthTest do
  use RenewCollab.DataCase

  alias RenewCollab.Auth

  describe "account" do
    alias RenewCollab.Auth.Account

    import RenewCollab.AuthFixtures

    @invalid_attrs %{password: nil, email: nil}

    test "list_account/0 returns all account" do
      account = account_fixture()
      assert Auth.list_account() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Auth.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{password: "some password", email: "some email"}

      assert {:ok, %Account{} = account} = Auth.create_account(valid_attrs)
      assert account.password == "some password"
      assert account.email == "some email"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      update_attrs = %{password: "some updated password", email: "some updated email"}

      assert {:ok, %Account{} = account} = Auth.update_account(account, update_attrs)
      assert account.password == "some updated password"
      assert account.email == "some updated email"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_account(account, @invalid_attrs)
      assert account == Auth.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Auth.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Auth.change_account(account)
    end
  end
end
