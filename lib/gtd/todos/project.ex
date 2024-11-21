defmodule Gtd.Todos.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :icon, :string, default: "🔨"
    field :title, :string
    field :user_id, :id

    field :status, Ecto.Enum,
      values: [:not_started, :in_progress, :completed],
      default: :not_started

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :user_id, :icon])
    |> validate_required([:title, :user_id])
  end
end
