# lib/gtd_web/live/components/task_list_component.ex
defmodule GtdWeb.TaskListComponent do
  use GtdWeb, :live_component
  require Logger

  alias GtdWeb.TaskFormComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <ul :for={task <- @tasks}>
        <li class="flex justify-between items-center p-4 bg-white shadow-md rounded-lg mt-2">
          <div class="flex items-center space-x-4">
            <div>
              <h3 class="text-lg font-bold"><%= task.title %></h3>
              <p class="text-gray-600"><%= task.content %></p>
            </div>
          </div>
          <div class="flex items-center space-x-4">
            <span class="text-sm text-gray-500">优先级: <%= priority(task.priority) %></span>
            <span class="text-sm text-gray-500">截止日期: <%= task.deadline %></span>
            <span class="bg-purple-200 text-purple-800 py-1 px-3 rounded-full">
              <%= if task.status != :completed do %>
                <button phx-click="finish_task" phx-value-task_id={task.id}>
                  <%= task_status(task.status) %>
                </button>
              <% else %>
                <span><%= task_status(task.status) %></span>
              <% end %>
            </span>
          </div>
        </li>
      </ul>
      <ul :if={@project}>
        <button
          phx-click="new_task"
          phx-value-project_id={@project.id}
          phx-target={@myself}
          class="mt-4 w-full gtd-button"
        >
          添加任务
        </button>
      </ul>
      <.live_component
        module={TaskFormComponent}
        id="task-form"
        show?={@new_task?}
        project_id={if @project, do: @project.id, else: nil}
      />
    </div>
    """
  end

  defp priority(priority) do
    case priority do
      0 -> "🔥🔥🔥"
      1 -> "🔥🔥"
      2 -> "🔥"
      _ -> "🪵"
    end
  end

  defp task_status(status) do
    case status do
      :completed -> "✔️"
      :in_progress -> "✊"
      _ -> "⌛️"
    end
  end

  @impl true
  def update(assigns, socket) do
    Logger.info("update task list component #{inspect(assigns)}")
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("finish_task", %{"task_id" => task_id}, socket) do
    send(self(), {:finish_task, task_id})
    {:noreply, socket}
  end

  def handle_event("new_task", %{"project_id" => project_id}, socket) do
    send_update(TaskFormComponent, id: "task-form", show?: true)

    socket
    |> assign(:project_id, project_id)
    |> assign(:new_task?, true)
    |> then(&{:noreply, &1})
  end
end
