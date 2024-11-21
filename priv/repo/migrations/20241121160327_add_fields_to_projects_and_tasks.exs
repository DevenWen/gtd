defmodule Gtd.Repo.Migrations.AddFieldsToProjectsAndTasks do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :status, :string, default: "not_started"
      add :icon, :string, default: "🔨"
    end

    alter table(:tasks) do
      add :status, :string, default: "not_started"
    end
  end
end
