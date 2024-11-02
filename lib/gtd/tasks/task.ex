defmodule Gtd.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string
    field :priority, :string
    field :due_date, :date
    belongs_to :project, Gtd.Projects.Project

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :priority, :due_date, :project_id])
    |> validate_required([:title, :status, :project_id])
    |> validate_inclusion(:status, ["pending", "in_progress", "completed"])
    |> validate_inclusion(:priority, ["low", "medium", "high"])
    |> foreign_key_constraint(:project_id)
  end
end
