defmodule Rocketpay.Accounts.DepositTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{Account, User}
  alias Rocketpay.Accounts.Deposit

  setup do
    params = %{
      name: "Mateus",
      password: "123456",
      nickname: "mateusfg7",
      email: "mateusfg7@protonmail.com",
      age: 18
    }

    {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

    {:ok, account_id: account_id}
  end

  describe "call/1" do
    test "when all params are valid, make a deposit", %{account_id: account_id} do
      params = %{"id" => account_id, "value" => "100.00"}

      {:ok, %Account{balance: balance}} = Deposit.call(params)

      {:ok, expected_balance} = Decimal.cast("100.00")

      assert balance == expected_balance
    end

    test "when the deposit value is negative, return an error", %{account_id: account_id} do
      params = %{"id" => account_id, "value" => "-100.00"}

      {:error, changeset} = Deposit.call(params)

      expected_response = %{balance: ["is invalid"]}

      assert errors_on(changeset) == expected_response
    end
  end
end
