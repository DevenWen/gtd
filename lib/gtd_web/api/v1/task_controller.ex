defmodule GtdWeb.Api.V1.TaskController do
  use GtdWeb, :controller

  alias Gtd.Tasks
  alias Gtd.Tasks.Task
  alias OpenApiSpex.Operation
  alias OpenApiSpex.Schema
  alias GtdWeb.Schemas.Task, as: TaskSchema
  use OpenApiSpex.ControllerSpecs
  require OpenApiSpex

  action_fallback GtdWeb.FallbackController

  operation(:index,
    tags: ["tasks"],
    summary: "List tasks",
    description: "List all tasks",
    responses: %{
      200 =>
        Operation.response(
          "Tasks",
          "application/json",
          %Schema{type: :object, properties: %{data: %Schema{type: :array, items: TaskSchema}}}
        )
    }
  )

  def index(conn, _params) do
    tasks = Tasks.list_tasks()
    render(conn, :index, tasks: tasks)
  end

  operation(:create,
    tags: ["tasks"],
    summary: "Create a task",
    description: "Create a new task",
    request_body:
      {"task object", "application/json", %Schema{type: :object, properties: %{task: TaskSchema}}},
    responses: %{
      201 =>
        Operation.response("Task", "application/json", %Schema{
          type: :object,
          properties: %{data: TaskSchema}
        })
    }
  )

  def create(conn, %{"task" => task_params}) do
    with {:ok, %Task{} = task} <- Tasks.create_task(task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/tasks/#{task}")
      |> render(:show, task: task)
    end
  end

  operation(:show,
    tags: ["tasks"],
    summary: "Get a task",
    description: "Get a task by ID",
    responses: %{
      200 => Operation.response("Task", "application/json", TaskSchema)
    }
  )

  def show(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    render(conn, :show, task: task)
  end

  operation(:update,
    tags: ["tasks"],
    summary: "Update a task",
    description: "Update a task by ID",
    request_body:
      {"task object", "application/json", %Schema{type: :object, properties: %{task: TaskSchema}}},
    responses: %{
      200 =>
        Operation.response("Task", "application/json", %Schema{
          type: :object,
          properties: %{data: TaskSchema}
        })
    }
  )

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Tasks.get_task!(id)

    with {:ok, %Task{} = task} <- Tasks.update_task(task, task_params) do
      render(conn, :show, task: task)
    end
  end

  operation(:delete,
    tags: ["tasks"],
    summary: "Delete a task",
    description: "Delete a task by ID",
    responses: %{
      204 => Operation.response("No Content", "application/text", nil)
    }
  )

  def delete(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)

    with {:ok, %Task{}} <- Tasks.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end
end
