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

      assert %{"message" => "Invalid deposit value!"} = response
    end
  end
end
