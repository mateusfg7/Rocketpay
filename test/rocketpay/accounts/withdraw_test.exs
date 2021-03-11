defmodule Rocketpay.Accounts.WithdrawTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{Account, User}
  alias Rocketpay.Accounts.Withdraw

  setup do
    params = %{
      name: "Mateus",
      password: "123456",
      nickname: "mateusfg7",
      email: "mateusfg7@protonmail.com",
      age: 18
    }

    {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

    Rocketpay.deposit(%{"id" => account_id, "value" => "100.00"})

    {:ok, account_id: account_id}
  end

  describe "call/1" do
    test "when all params are valid, make a withdraw", %{account_id: account_id} do
      params = %{"id" => account_id, "value" => "50.00"}

      {:ok, %Account{balance: balance}} = Withdraw.call(params)

      {:ok, expected_balance} = Decimal.cast("50.00")

      assert balance == expected_balance
    end

    test "when the withdraw value is greather than balance, return an error", %{
      account_id: account_id
    } do
      params = %{"id" => account_id, "value" => "150.00"}

      {:error, changeset} = Withdraw.call(params)

      expected_response = %{balance: ["is invalidd"]}

      assert errors_on(changeset) == expected_response
    end
  end
end
