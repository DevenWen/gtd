defmodule Gtd.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gtd.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        description: "some description",
        due_date: ~D[2024-11-01],
        priority: "low",
        status: "pending",
        title: "some title"
      })
      |> Gtd.Tasks.create_task()

    task
  end
end
