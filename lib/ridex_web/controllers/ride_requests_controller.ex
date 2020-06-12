defmodule RidexWeb.RideRequestsController do
  use RidexWeb, :controller

  def create(
        conn,
        %{
          "geohash" => geohash,
          "position" => position
        } = _params
      ) do
    # Assuming we are authenticating user with a plug before and store it in conn.assigns
    rider = conn.assigns[:current_user]

    case Ridex.RideRequest.create(rider, position) do
      {:ok, request} ->
        RidexWeb.Endpoint.broadcast("cell:#{geohash}", "ride:requested", %{
          request_id: request.id,
          position: position
        })

        conn |> json(%{"request" => request})

      {:error, _reason} ->
        conn |> json(%{"error" => "Unable to request a ride"})
    end
  end
end
