# Rocketpay

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Routes (dev)

### Create User

_**Example Request**_

```http
POST /api/users HTTP/1.1
Host: 0.0.0.0:4000
Content-Type: application/json; charset=utf-8

{
	"name": "Mateus Felipe Gonçalves",
	"nickname": "mateusfg7",
	"email": "mateus@email.com",
	"age": 18,
	"password": "x7#Fv84Sa4$d7"
}
```

_**Example Response**_

HTTP Status Code: `201`

Response Body:
```json
{
  "message": "User created",
  "user": {
    "account": {
      "balance": "0.00",
      "id": "e6987693-d884-4bd6-b429-f089e2bf2d3f"
    },
    "id": "ce605574-675b-4965-a812-2b7487d077d4",
    "name": "Mateus Felipe Gonçalves",
    "nickname": "mateusfg7"
  }
}
```


## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
