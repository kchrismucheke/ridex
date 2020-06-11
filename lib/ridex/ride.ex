defmodule Ridex.Ride do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rides" do
    field :lat, :float
    field :lng, :float
    field :rider_id, :id
    field :driver_id, :id

    timestamps()
  end

  @doc false
  def changeset(ride, attrs) do
    ride
    |> cast(attrs, [:lat, :lng])
    |> validate_required([:lat, :lng])
  end

  def create(rider_id, driver_id, %{"lat" => lat, "lng" => lng}) do
    %Ridex.Ride{
      rider_id: rider_id,
      driver_id: driver_id,
      lat: lat,
      lng: lng
    }
    |> Ridex.Repo.insert()
  end
end
