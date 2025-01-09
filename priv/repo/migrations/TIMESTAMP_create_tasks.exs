defmodule Gtd.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :content, :text
      add :priority, :integer
      add :deadline, :naive_datetime
      add :project_id, references(:projects)
      add :user_id, references(:users)

      timestamps()
    end

    create index(:tasks, [:project_id])
    create index(:tasks, [:user_id])
  end
end
