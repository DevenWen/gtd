defmodule Gtd.Accounts.Identity do
  use Ecto.Schema
  # import Ecto.Changeset
  alias Gtd.Accounts.User

  @derive {Inspect, except: [:provider_token, :provider_meta]}
  schema "identities" do
    field :provider, :string
    field :provider_token, :string
    field :provider_email, :string
    field :provider_login, :string
    field :provider_name, :string, virtual: true
    field :provider_id, :string
    field :provider_meta, :map

    belongs_to :user, User

    timestamps()
  end
end
