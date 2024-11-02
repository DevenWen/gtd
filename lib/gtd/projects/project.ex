defmodule Gtd.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :status, :string
    field :description, :string
    field :due_date, :date

    has_many :tasks, Gtd.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :status, :due_date])
    |> validate_required([:name, :description, :status, :due_date])
  end
end
