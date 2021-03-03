defmodule Rocketpay.Users.CreateTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.User
  alias Rocketpay.Users.Create

  describe "call/1" do
    test "when all params are valid, return an user" do
      params = %{
        name: "Mateus",
        password: "123456",
        nickname: "mateusfg7",
        email: "mateusfg7@protonmail.com",
        age: 18
      }

      {:ok, %User{id: user_id}} = Create.call(params)

      user = Repo.get(User, user_id)

      assert %User{name: "Mateus", age: 18, id: ^user_id} = user
    end

    test "when there are invalid params, return an error" do
      params = %{
        name: "Mateus",
        nickname: "mateusfg7",
        email: "mateusfg7@protonmail.com",
        age: 15
      }

      {:error, changeset} = Create.call(params)

      expected_response = %{
        age: ["must be greater than or equal to 18"],
        password: ["can't be blank"]
      }

      assert errors_on(changeset) == expected_response
    end
  end
end
