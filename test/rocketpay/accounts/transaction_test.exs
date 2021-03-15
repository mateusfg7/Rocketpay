defmodule Rocketpay.Accounts.TransactionTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{Account, User}
  alias Rocketpay.Accounts.Transaction
  alias Rocketpay.Accounts.Transactions.Response

  setup do
    user_a = %{
      name: "User A",
      password: "123456",
      nickname: "user_a",
      email: "user_a@email.com",
      age: 20
    }

    user_b = %{
      name: "User B",
      password: "123456",
      nickname: "user_b",
      email: "user_b@email.com",
      age: 20
    }

    {:ok, %User{account: %Account{id: user_a_account_id}}} = Rocketpay.create_user(user_a)

    {:ok, %User{account: %Account{id: user_b_account_id}}} = Rocketpay.create_user(user_b)

    Rocketpay.deposit(%{"id" => user_a_account_id, "value" => "100.00"})

    {:ok, user_a_account_id: user_a_account_id, user_b_account_id: user_b_account_id}
  end

  describe "call/1" do
    test "when all params are valid, make a transaction from user A to user B", %{
      user_a_account_id: user_a_account_id,
      user_b_account_id: user_b_account_id
    } do
      params = %{"from" => user_a_account_id, "to" => user_b_account_id, "value" => "50.00"}

      {:ok,
       %Response{
         from_account: %Account{
           balance: user_a_balance
         },
         to_account: %Account{
           balance: user_b_balance
         }
       }} = Transaction.call(params)

      {:ok, expected_user_a_balance} = Decimal.cast("50.00")
      {:ok, expected_user_b_balance} = Decimal.cast("50.00")

      assert user_a_balance == expected_user_a_balance
      assert user_b_balance == expected_user_b_balance
    end

    test "when the transaction value is greather than the balance, return an error", %{
      user_a_account_id: user_a_account_id,
      user_b_account_id: user_b_account_id
    } do
      params = %{"from" => user_a_account_id, "to" => user_b_account_id, "value" => "150.00"}

      {:error, changeset} = Transaction.call(params)

      expected_response = %{balance: ["is invalid"]}

      assert errors_on(changeset) == expected_response
    end
  end
end
