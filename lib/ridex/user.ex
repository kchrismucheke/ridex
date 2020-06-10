defmodule Ridex.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ridex.User

  schema "users" do
    field :phone, :string
    field :type, :string

    timestamps()
  end

  def get_or_create(phone, type) do
    case Ridex.Repo.get_by(User, phone: phone, type: type) do
      nil ->
        %User{phone: phone, type: type}
        |> Ridex.Repo.insert()

      user ->
        {:ok, user}
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:type, :name, :phone])
    |> validate_required([:type, :name, :phone])
  end
end
