defmodule Gtd.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Gtd.Accounts.Identity

  schema "users" do
    field :email, :string
    field :name, :string
    field :username, :string
    field :confirmed_at, :utc_datetime
    field :avatar_url, :string

    has_many :identities, Identity

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Gtd.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end
end
