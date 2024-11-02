defmodule GtdWeb.TaskControllerTest do
  use GtdWeb.ConnCase

  import Gtd.TasksFixtures
  import Gtd.ProjectsFixtures

  alias Gtd.Tasks.Task

  @create_attrs %{
    priority: "low",
    status: "pending",
    description: "some description",
    title: "some title",
    project_id: nil,
    due_date: ~D[2024-11-01]
  }
  @update_attrs %{
    priority: "medium",
    status: "in_progress",
    description: "some updated description",
    title: "some updated title",
    due_date: ~D[2024-11-02]
  }
  @invalid_attrs %{priority: nil, status: nil, description: nil, title: nil, due_date: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tasks", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/tasks")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create task" do
    setup [:create_task]

    test "renders task when data is valid", %{conn: conn, project: project} do
      conn = post(conn, ~p"/api/v1/tasks", task: %{@create_attrs | project_id: project.id})
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/v1/tasks/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some description",
               "due_date" => "2024-11-01",
               "priority" => "low",
               "status" => "pending",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/tasks", task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update task" do
    setup [:create_task]

    test "renders task when data is valid", %{conn: conn, task: %Task{id: id} = task} do
      conn = put(conn, ~p"/api/v1/tasks/#{task}", task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/v1/tasks/#{id}")

      assert %{
               "id" => ^id,
               "description" => "some updated description",
               "due_date" => "2024-11-02",
               "priority" => "medium",
               "status" => "in_progress",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, ~p"/api/v1/tasks/#{task}", task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete(conn, ~p"/api/v1/tasks/#{task}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/tasks/#{task}")
      end
    end
  end

  defp create_task(_) do
    project = project_fixture()
    task = task_fixture(%{project_id: project.id})
    %{task: task, project: project}
  end
end
