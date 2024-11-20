defmodule Gtd.Todos.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :priority, :integer
    field :title, :string
    field :deadline, :naive_datetime
    field :content, :string
    field :user_id, :id
    field :project_id, :id
    field :parent_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :content, :priority, :deadline, :project_id, :user_id])
    |> validate_required([:title, :content, :priority, :deadline, :project_id, :user_id])
  end
end
