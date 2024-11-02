defmodule GtdWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule Task do
    OpenApiSpex.schema(%{
      title: "Task",
      description: "Task schema",
      type: :object,
      properties: %{
        title: %Schema{type: :string, description: "Task title", example: "完成报告"},
        description: %Schema{
          type: :string,
          description: "Task description",
          example: "详细描述任务内容"
        },
        status: %Schema{
          type: :string,
          enum: ["pending", "in_progress", "completed"],
          example: "pending"
        },
        priority: %Schema{type: :string, enum: ["low", "medium", "high"], example: "high"},
        due_date: %Schema{
          type: :string,
          format: :date,
          description: "Due date",
          example: "2024-03-20"
        },
        project_id: %Schema{type: :integer, description: "Project ID", example: 1}
      },
      required: [:title, :status, :project_id]
    })
  end

  defmodule Project do
    OpenApiSpex.schema(%{
      title: "Project",
      description: "POST body for creating a project",
      type: :object,
      properties: %{
        name: %Schema{type: :string, description: "项目名称", example: "GTD系统开发"},
        description: %Schema{type: :string, description: "项目描述", example: "开发一个GTD任务管理系统"},
        status: %Schema{type: :string, description: "项目状态", example: "进行中"},
        due_date: %Schema{
          type: :string,
          format: :date,
          description: "截止日期",
          example: "2024-12-31"
        }
      },
      required: [:name, :description, :status, :due_date]
    })
  end
end
