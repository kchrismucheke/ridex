defmodule RidexWeb.CellChannel do
  use RidexWeb, :channel

  intercept ["ride:requested"]

  def join("cell:" <> _geohash, %{"position" => position}, socket) do
    send(self(), {:after_join, position})
    {:ok, %{}, socket}
  end

  def handle_info({:after_join, position}, socket) do
    user = socket.assigns[:current_user]

    if user.type == "driver" do
      RidexWeb.Presence.track(socket, user.id, %{
        lat: position["lat"],
        lng: position["lng"]
      })
    end

    push(socket, "presence_state", RidexWeb.Presence.list(socket))

    {:noreply, socket}
  end

  def handle_in("ride:request", %{"position" => position}, socket) do
    case Ridex.RideRequest.create(socket.assigns[:current_user], position) do
      {:ok, request} ->
        broadcast!(socket, "ride:requested", %{request_id: request.id, position: position})
        {:reply, :ok, socket}

      {:error, _changeset} ->
        {:reply, {:errir, :insert_error}, socket}
    end
  end

  def handle_in("ride:request_accepted", %{"request_id" => request_id}, socket) do
    case Ridex.Repo.get(Ridex.RideRequest, request_id) do
      nil ->
        {:reply, :error, socket}

      request ->
        case Ridex.Ride.create(
               request.rider_id,
               socket.assigns[:current_user].id,
               %{"lat" => request.lat, "lng" => request.lng}
             ) do
          {:ok, ride} ->
            RidexWeb.Endpoint.broadcast("user:#{ride.driver_id}", "ride:created", %{
              ride_id: ride.id
            })

            RidexWeb.Endpoint.broadcast("user:#{ride.rider_id}", "ride:created", %{
              ride_id: ride.id
            })

            {:reply, :ok, socket}

          {:error, _changeset} ->
            {:reply, :error, socket}
        end
    end
  end

  def handle_out("ride:requested", payload, socket) do
    if socket.assigns[:current_user].type == "driver" do
      push(socket, "ride:requested", payload)
    end

    {:noreply, socket}
  end
end
