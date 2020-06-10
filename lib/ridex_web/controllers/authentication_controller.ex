defmodule RidexWeb.AuthenticationController do
  use RidexWeb, :controller
  alias Ridex.User

  plug :validate_user_type

  def authenticate(conn, %{"phone" => phone, "type" => type}) do
    with {:ok, user} <- User.get_or_create(phone, type),
         {:ok, token, _claims} = Ridex.Guardian.encode_and_sign(user) do
      conn
      |> json(%{
        "id" => user.id,
        "token" => token,
        "type" => user.type
      })
    else
      {:error, reason} ->
        conn
        |> json(%{"error" => "Error authenticating: #{reason}"})
    end
  end

  def validate_user_type(conn, _) do
    case conn.params["type"] do
      type when type in ["driver", "rider"] ->
        conn

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{"error" => "Invalid user type"})
        |> halt()
    end
  end
end
