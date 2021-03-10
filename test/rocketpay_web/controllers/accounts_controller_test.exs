defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      params = %{
        name: "Mateus",
        password: "123456",
        nickname: "mateusfg7",
        email: "mateusfg7@protonmail.com",
        age: 18
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:ok)

      assert %{
               "account" => %{"balance" => "50.00", "id" => _id},
               "message" => "Ballance changed successfully"
             } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "cinquenta"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value!"}

      assert response == expected_response
    end
  end

  describe "withdraw/2" do
    setup %{conn: conn} do
      params = %{
        name: "Mateus",
        password: "123456",
        nickname: "mateusfg7",
        email: "mateusfg7@protonmail.com",
        age: 18
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit, after, the withdraw", %{
      conn: conn,
      account_id: account_id
    } do
      deposit_params = %{"value" => "100.00"}
      withdraw_params = %{"value" => "50.00"}

      conn |> post(Routes.accounts_path(conn, :deposit, account_id, deposit_params))

      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, withdraw_params))
        |> json_response(:ok)

      assert %{
               "account" => %{"balance" => "50.00", "id" => _id},
               "message" => "Ballance changed successfully"
             } = response
    end

    test "when the withdraw value is greather than the balance, return an error", %{
      conn: conn,
      account_id: account_id
    } do
      deposit_params = %{"value" => "50.00"}
      withdraw_params = %{"value" => "100.00"}

      conn |> post(Routes.accounts_path(conn, :deposit, account_id, deposit_params))

      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, withdraw_params))
        |> json_response(:bad_request)

      expected_response = %{"message" => %{"balance" => ["is invalid"]}}

      assert response == expected_response
    end

    test "when there are invalid params, return an error", %{
      conn: conn,
      account_id: account_id
    } do
      deposit_params = %{"value" => "100.00"}
      withdraw_params = %{"value" => "cinquenta"}

      conn |> post(Routes.accounts_path(conn, :deposit, account_id, deposit_params))

      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, withdraw_params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value!"}

      assert response == expected_response
    end
  end

  describe "transaction/2" do
    setup %{conn: conn} do
      user_a_params = %{
        name: "Mateus",
        password: "123456",
        nickname: "mateusfg7",
        email: "mateusfg7@protonmail.com",
        age: 18
      }

      user_b_params = %{
        name: "Felipe",
        password: "654321",
        nickname: "mateusfg8",
        email: "mateusfg7@gmail.com",
        age: 18
      }

      {:ok, %User{account: %Account{id: user_a_account_id}}} =
        Rocketpay.create_user(user_a_params)

      {:ok, %User{account: %Account{id: user_b_account_id}}} =
        Rocketpay.create_user(user_b_params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok,
       conn: conn, user_a_account_id: user_a_account_id, user_b_account_id: user_b_account_id}
    end

    test "when all params are valid make a transaction from user A, to user B", %{
      conn: conn,
      user_a_account_id: user_a_account_id,
      user_b_account_id: user_b_account_id
    } do
      deposit = %{"value" => "100.00"}
      transaction = %{"from" => user_a_account_id, "to" => user_b_account_id, "value" => "50.00"}

      conn |> post(Routes.accounts_path(conn, :deposit, user_a_account_id, deposit))

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, transaction))
        |> json_response(:ok)

      assert %{
               "message" => "Transaction done successfully",
               "transaction" => %{
                 "from_account" => %{"balance" => "50.00", "id" => _id_a},
                 "to_account" => %{"balance" => "50.00", "id" => _id_b}
               }
             } = response
    end

    test "when the transaction amount is greather than the balance, return an error", %{
      conn: conn,
      user_a_account_id: user_a_account_id,
      user_b_account_id: user_b_account_id
    } do
      deposit = %{"value" => "100.00"}
      transaction = %{"from" => user_a_account_id, "to" => user_b_account_id, "value" => "150.00"}

      conn |> post(Routes.accounts_path(conn, :deposit, user_a_account_id, deposit))

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, transaction))
        |> json_response(:bad_request)

      expected_response = %{"message" => %{"balance" => ["is invalid"]}}

      assert response == expected_response
    end

    test "when there are invalid params, return an error", %{
      conn: conn,
      user_a_account_id: user_a_account_id,
      user_b_account_id: user_b_account_id
    } do
      deposit = %{"value" => "100.00"}

      transaction = %{
        "from" => user_a_account_id,
        "to" => user_b_account_id,
        "value" => "cinquenta"
      }

      conn |> post(Routes.accounts_path(conn, :deposit, user_a_account_id, deposit))

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, transaction))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value!"}

      assert response == expected_response
    end
  end
end
