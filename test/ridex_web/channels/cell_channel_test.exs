defmodule RidexWeb.CellChannelTest do
  use RidexWeb.ChannelCase, async: true

  alias Ridex.User
  alias RidexWeb.{UserSocket, CellChannel}

  setup do
    {:ok, rider} = User.get_or_create("+5531983000000", "rider")
    {:ok, driver} = User.get_or_create("+5531988888888", "driver")

    {:ok, _, rider_socket} =
      UserSocket
      |> socket(rider.id, %{current_user: rider})
      |> subscribe_and_join(CellChannel, "cell:xyz")

    {:ok, _, driver_socket} =
      UserSocket
      |> socket(driver.id, %{current_user: driver})
      |> subscribe_and_join(CellChannel, "cell:xyz")

    %{
      rider_socket: rider_socket,
      driver_socket: driver_socket,
      rider: rider,
      driver: driver
    }
  end

  test "creates ride request", %{rider_socket: rider_socket} do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}

    ref = push(rider_socket, "ride:request", %{position: position})
    assert_reply ref, :ok, %{}

    [request] = Ridex.RideRequest |> Ridex.Repo.all()

    assert request.lat == position["lat"]
    assert request.lng == position["lng"]
  end

  test "broadcast ride request message", %{rider_socket: rider_socket} do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}

    ref = push(rider_socket, "ride:request", %{position: position})
    assert_reply ref, :ok, %{}

    [%{id: _}] = Ridex.RideRequest |> Ridex.Repo.all()

    assert_broadcast("ride:requested", %{request_id: request_id, position: position})
  end

  test "accepts a ride request and creates ride", %{
    driver_socket: driver_socket,
    rider: rider,
    driver: driver
  } do
    position = %{"lat" => 51.36577, "lng" => 0.6476747}
    {:ok, request} = Ridex.RideRequest.create(rider, position)

    ref = push(driver_socket, "ride:request_accepted", %{request_id: request.id})
    assert_reply ref, :ok, %{}

    assert [ride] = Ridex.Ride |> Ridex.Repo.all()
    assert ride.driver_id == driver.id
    assert ride.rider_id == rider.id
  end

  test "fails to accept a non existing ride request", %{driver_socket: driver_socket} do
    ref = push(driver_socket, "ride:request_accepted", %{request_id: 123})
    assert_reply ref, :error, %{}

    assert [] = Ridex.Ride |> Ridex.Repo.all()
  end

  test "broadcasts ride:created to both users", %{
    driver_socket: driver_socket,
    rider: rider,
    driver: driver
  } do
    Phoenix.PubSub.subscribe(Ridex.PubSub, "user:#{rider.id}")
    Phoenix.PubSub.subscribe(Ridex.PubSub, "user:#{driver.id}")

    position = %{"lat" => 51.36577, "lng" => 0.6476747}
    {:ok, request} = Ridex.RideRequest.create(rider, position)

    ref = push(driver_socket, "ride:request_accepted", %{request_id: request.id})
    assert_reply ref, :ok, %{}

    [%{id: ride_id}] = Ridex.Ride |> Ridex.Repo.all()

    assert_receive %Phoenix.Socket.Broadcast{
      event: "ride:created",
      payload: %{ride_id: ride_id}
    }

    assert_receive %Phoenix.Socket.Broadcast{
      event: "ride:created",
      payload: %{ride_id: ride_id}
    }
  end
end
