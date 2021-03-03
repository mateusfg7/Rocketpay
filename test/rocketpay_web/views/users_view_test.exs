defmodule RocketpayWeb.UsersViewTest do
  use RocketpayWeb.ConnCase, async: true

  import Phoenix.View

  alias RocketpayWeb.UsersView
  alias Rocketpay.{Account, User}

  test "renders create.json" do
    params = %{
      name: "Mateus",
      password: "123456",
      nickname: "mateusfg7",
      email: "mateusfg7@protonmail.com",
      age: 18
    }

    {:ok, %User{id: user_id, account: %Account{id: account_id}} = user} =
      Rocketpay.create_user(params)

    response = render(UsersView, "create.json", user: user)

    expected_response = %{
      message: "User created",
      user: %{
        account: %{
          balance: Decimal.new("0.00"),
          id: account_id
        },
        id: user_id,
        name: "Mateus",
        nickname: "mateusfg7"
      }
    }

    assert expected_response == response
  end
end
