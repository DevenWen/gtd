defmodule GtdWeb.Api.V1.ProjectJSON do
  alias Gtd.Projects.Project

  @doc """
  Renders a list of projects.
  """
  def index(%{projects: projects}) do
    %{data: for(project <- projects, do: data(project))}
  end

  @doc """
  Renders a single project.
  """
  def show(%{project: project}) do
    %{data: data(project)}
  end

  defp data(%Project{} = project) do
    %{
      id: project.id,
      name: project.name,
      description: project.description,
      status: project.status,
      due_date: project.due_date
    }
  end
end
