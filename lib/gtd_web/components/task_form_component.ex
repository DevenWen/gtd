# lib/gtd_web/live/components/task_form_component.ex
defmodule GtdWeb.TaskFormComponent do
  use GtdWeb, :live_component
  alias Gtd.Todos
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@show?} class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
        <div class="bg-white p-6 rounded-lg shadow-lg w-1/2">
          <span
            class="close text-gray-500 hover:text-gray-700 cursor-pointer float-right"
            phx-click="close_modal"
            phx-target={@myself}
          >
            &times;
          </span>
          <h2 class="text-2xl font-semibold mb-4">新建任务</h2>
          <form
            phx-submit="commit_task"
            phx-value-project_id={@project_id}
            target={@myself}
            class="space-y-4"
          >
            <input
              type="text"
              name="title"
              placeholder="任务标题"
              required
              class="w-full p-2 border border-gray-300 rounded"
            />
            <textarea
              name="content"
              placeholder="任务内容"
              required
              class="w-full p-2 border border-gray-300 rounded"
            ></textarea>
            <input
              type="number"
              name="priority"
              placeholder="优先级"
              required
              class="w-full p-2 border border-gray-300 rounded"
            />
            <input
              type="datetime-local"
              name="deadline"
              required
              class="w-full p-2 border border-gray-300 rounded"
            />
            <button type="submit" class="gtd-button">
              提交
            </button>
          </form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    Logger.info("update task form component #{inspect(assigns)}")
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("commit_task", params, socket) do
    # send(self(), {:commit_task, para
    project_id = socket.assigns.project_id
    deadline_with_seconds = "#{params["deadline"]}:00.000Z"

    case NaiveDateTime.from_iso8601(deadline_with_seconds) do
      {:ok, naive_datetime} ->
        {:ok, task} =
          Todos.create_task(%{
            title: params["title"],
            content: params["content"],
            priority: String.to_integer(params["priority"]),
            deadline: naive_datetime,
            project_id: project_id,
            user_id: socket.assigns.current_user.id
          })

        Logger.info("创建任务后: #{inspect(task)}")
        # send(self(), {:commit_task, params})
        {:noreply, socket}

      {:error, reason} ->
        Logger.error("无效的截止日期格式: #{reason}")
        {:noreply, put_flash(socket, :error, "无效的截止日期格式。")}
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    send(self(), :close_modal)
    {:noreply, assign(socket, :show?, false)}
  end
end
