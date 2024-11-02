defmodule Gtd.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gtd.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        description: "some description",
        due_date: ~D[2024-11-01],
        name: "some name",
        status: "some status"
      })
      |> Gtd.Projects.create_project()

    project
  end
end
