defmodule Gtd.Repo.Migrations.RefactorUser do
  use Ecto.Migration

  def change do
    # 删除此前的表
    drop table("users_tokens")
    drop table("users")

    create table(:users) do
      add :email, :string
      add :name, :string
      add :username, :string
      add :confirmed_at, :naive_datetime
      add :avatar_url, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])

    # identity 表
    create table(:identities) do
      add :provider, :string
      add :provider_token, :string
      add :provider_email, :string
      add :provider_login, :string
      add :provider_name, :string
      add :provider_id, :string
      add :provider_meta, :map

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:identities, [:user_id])
    create unique_index(:identities, [:user_id, :provider])

    # users_token
    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
