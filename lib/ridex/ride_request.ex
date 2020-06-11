defmodule Ridex.RideRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ride_requests" do
    field :lat, :float
    field :lng, :float
    field :rider_id, :id

    timestamps()
  end

  @doc false
  def changeset(ride_request, attrs) do
    ride_request
    |> cast(attrs, [:lat, :lng])
    |> validate_required([:lat, :lng])
  end

  def create(rider, %{"lat" => lat, "lng" => lng}) do
    %Ridex.RideRequest{
      rider_id: rider.id,
      lat: lat,
      lng: lng
    }
    |> Ridex.Repo.insert()
  end
end
