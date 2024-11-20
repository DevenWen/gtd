defmodule Gtd.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    drop table("tasks")
    drop table("projects")

    create table(:projects) do
      add :title, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:user_id])
  end
end
