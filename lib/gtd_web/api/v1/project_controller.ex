defmodule GtdWeb.Api.V1.ProjectController do
  use GtdWeb, :controller

  alias Gtd.Projects
  alias Gtd.Projects.Project
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema
  alias GtdWeb.Schemas.Project, as: ProjectSchema
  use OpenApiSpex.ControllerSpecs
  require OpenApiSpex

  action_fallback GtdWeb.FallbackController

  operation(:index,
    tags: ["projects"],
    summary: "List projects",
    description: "List all projects",
    responses: %{
      200 =>
        Operation.response("Projects", "application/json", %Schema{
          type: :object,
          properties: %{data: %Schema{type: :array, items: ProjectSchema}}
        })
    }
  )

  def index(conn, _params) do
    projects = Projects.list_projects()
    render(conn, :index, projects: projects)
  end

  operation(:create,
    tags: ["projects"],
    summary: "Create a project",
    description: "Create a new project",
    request_body:
      {"project object", "application/json",
       %Schema{type: :object, properties: %{project: ProjectSchema}}},
    responses: %{
      201 =>
        Operation.response("Project", "application/json", %Schema{
          type: :object,
          properties: %{data: ProjectSchema}
        })
    }
  )

  def create(conn, %{"project" => project_params}) do
    with {:ok, %Project{} = project} <- Projects.create_project(project_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/projects/#{project}")
      |> render(:show, project: project)
    end
  end

  operation(:show,
    tags: ["projects"],
    summary: "Get a project",
    description: "Get a project by ID",
    responses: %{
      200 =>
        Operation.response("Project", "application/json", %Schema{
          type: :object,
          properties: %{data: ProjectSchema}
        })
    }
  )

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(id)
    render(conn, :show, project: project)
  end

  operation(:update,
    tags: ["projects"],
    summary: "Update a project",
    description: "Update a project by ID",
    request_body:
      {"project object", "application/json",
       %Schema{type: :object, properties: %{project: ProjectSchema}}},
    responses: %{
      200 =>
        Operation.response("Project", "application/json", %Schema{
          type: :object,
          properties: %{data: ProjectSchema}
        })
    }
  )

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Projects.get_project!(id)

    with {:ok, %Project{} = project} <- Projects.update_project(project, project_params) do
      render(conn, :show, project: project)
    end
  end

  operation(:delete,
    tags: ["projects"],
    summary: "Delete a project",
    description: "Delete a project by ID",
    responses: %{
      204 => Operation.response("No Content", "application/text", nil)
    }
  )

  def delete(conn, %{"id" => id}) do
    project = Projects.get_project!(id)

    with {:ok, %Project{}} <- Projects.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end
end
