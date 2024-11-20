defmodule Gtd.Todos.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :title, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
  end
end
