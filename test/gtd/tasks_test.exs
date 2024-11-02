defmodule Gtd.TasksTest do
  use Gtd.DataCase

  alias Gtd.Tasks

  describe "tasks" do
    alias Gtd.Tasks.Task

    import Gtd.TasksFixtures
    import Gtd.ProjectsFixtures

    @invalid_attrs %{priority: nil, status: nil, description: nil, title: nil, due_date: nil}

    test "list_tasks/0 returns all tasks" do
      project = project_fixture()
      task = task_fixture(%{project_id: project.id})
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      project = project_fixture()
      task = task_fixture(%{project_id: project.id})
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      project = project_fixture()

      valid_attrs = %{
        priority: "low",
        status: "pending",
        description: "some description",
        title: "some title",
        project_id: project.id,
        due_date: ~D[2024-11-01]
      }

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.priority == "low"
      assert task.status == "pending"
      assert task.description == "some description"
      assert task.title == "some title"
      assert task.due_date == ~D[2024-11-01]
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      project = project_fixture()
      task = task_fixture(%{project_id: project.id})

      update_attrs = %{
        priority: "medium",
        status: "in_progress",
        description: "some updated description",
        title: "some updated title",
        due_date: ~D[2024-11-02]
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.priority == "medium"
      assert task.status == "in_progress"
      assert task.description == "some updated description"
      assert task.title == "some updated title"
      assert task.due_date == ~D[2024-11-02]
    end

    test "update_task/2 with invalid data returns error changeset" do
      project = project_fixture()
      task = task_fixture(%{project_id: project.id})
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      project = project_fixture()
      task = task_fixture(%{project_id: project.id})
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      project = project_fixture()
      task = task_fixture(%{project_id: project.id})
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
