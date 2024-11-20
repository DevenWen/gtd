defmodule Gtd.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :content, :string
      add :priority, :integer
      add :deadline, :naive_datetime
      add :user_id, references(:users, on_delete: :nothing)
      add :project_id, references(:projects, on_delete: :nothing)
      add :parent_id, references(:tasks, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:user_id, :project_id])
    create index(:tasks, [:project_id])
    create index(:tasks, [:parent_id])
  end
end
