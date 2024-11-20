defmodule Gtd.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gtd.Todos` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Gtd.Todos.create_project()

    project
  end

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        content: "some content",
        deadline: ~N[2024-11-16 12:57:00],
        priority: 42,
        title: "some title"
      })
      |> Gtd.Todos.create_task()

    task
  end
end
