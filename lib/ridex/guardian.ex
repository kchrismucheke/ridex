defmodule Ridex.Guardian do
  use Guardian, otp_app: :ridex

  def subject_for_token(%{id: user_id}, _claims) do
    {:ok, user_id}
  end

  def resource_from_claims(%{"sub" => subject}) do
    case Ridex.Repo.get(Ridex.User, subject) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
