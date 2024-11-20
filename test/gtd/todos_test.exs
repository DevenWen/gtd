defmodule Gtd.TodosTest do
  use Gtd.DataCase

  alias Gtd.Todos

  setup %{} do
    user = Gtd.AccountsFixtures.user_fixture()
    project = Gtd.TodosFixtures.project_fixture(%{user_id: user.id})
    {:ok, user: user, project: project}
  end

  describe "projects" do
    alias Gtd.Todos.Project

    import Gtd.TodosFixtures

    @invalid_attrs %{title: nil}

    test "list_projects/0 returns all projects", %{project: project} do
      assert Todos.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id", %{project: project} do
      assert Todos.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project", %{user: user} do
      valid_attrs = %{title: "some title", user_id: user.id}

      assert {:ok, %Project{} = project} = Todos.create_project(valid_attrs)
      assert project.title == "some title"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project", %{user: user} do
      project = project_fixture(%{user_id: user.id})
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Project{} = project} = Todos.update_project(project, update_attrs)
      assert project.title == "some updated title"
    end

    test "update_project/2 with invalid data returns error changeset", %{user: user} do
      project = project_fixture(%{user_id: user.id})
      assert {:error, %Ecto.Changeset{}} = Todos.update_project(project, @invalid_attrs)
      assert project == Todos.get_project!(project.id)
    end

    test "delete_project/1 deletes the project", %{user: user} do
      project = project_fixture(%{user_id: user.id})
      assert {:ok, %Project{}} = Todos.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset", %{user: user} do
      project = project_fixture(%{user_id: user.id})
      assert %Ecto.Changeset{} = Todos.change_project(project)
    end
  end

  describe "tasks" do
    alias Gtd.Todos.Task

    import Gtd.TodosFixtures

    @invalid_attrs %{priority: nil, title: nil, deadline: nil, content: nil}

    test "list_tasks/0 returns all tasks", %{user: user, project: project} do
      task = task_fixture(%{user_id: user.id, project_id: project.id})
      assert Todos.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id", %{user: user, project: project} do
      task = task_fixture(%{user_id: user.id, project_id: project.id})
      assert Todos.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task", %{user: user, project: project} do
      valid_attrs = %{
        user_id: user.id,
        project_id: project.id,
        priority: 42,
        title: "some title",
        deadline: ~N[2024-11-16 12:57:00],
        content: "some content"
      }

      assert {:ok, %Task{} = task} = Todos.create_task(valid_attrs)
      assert task.priority == 42
      assert task.title == "some title"
      assert task.deadline == ~N[2024-11-16 12:57:00]
      assert task.content == "some content"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task", %{user: user, project: project} do
      task = task_fixture(%{user_id: user.id, project_id: project.id})

      update_attrs = %{
        priority: 43,
        title: "some updated title",
        deadline: ~N[2024-11-17 12:57:00],
        content: "some updated content"
      }

      assert {:ok, %Task{} = task} = Todos.update_task(task, update_attrs)
      assert task.priority == 43
      assert task.title == "some updated title"
      assert task.deadline == ~N[2024-11-17 12:57:00]
      assert task.content == "some updated content"
    end

    test "update_task/2 with invalid data returns error changeset", %{
      user: user,
      project: project
    } do
      task = task_fixture(%{user_id: user.id, project_id: project.id})
      assert {:error, %Ecto.Changeset{}} = Todos.update_task(task, @invalid_attrs)
      assert task == Todos.get_task!(task.id)
    end

    test "delete_task/1 deletes the task", %{user: user, project: project} do
      task = task_fixture(%{user_id: user.id, project_id: project.id})
      assert {:ok, %Task{}} = Todos.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset", %{user: user, project: project} do
      task = task_fixture(%{user_id: user.id, project_id: project.id})
      assert %Ecto.Changeset{} = Todos.change_task(task)
    end
  end
end
