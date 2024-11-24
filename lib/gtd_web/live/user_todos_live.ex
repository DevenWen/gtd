defmodule GtdWeb.UserTodosLive do
  use GtdWeb, :live_view
  alias Gtd.Todos
  require Logger

  defstruct selected_project: nil, projects: [], tasks: [], new_task: %{}

  @doc """
  Renders a form for creating a new task.
  """
  def task_form(assigns) do
    ~H"""
    <%= if @show do %>
      <div class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
        <div class="bg-white p-6 rounded-lg shadow-lg w-1/2">
          <span
            class="close text-gray-500 hover:text-gray-700 cursor-pointer float-right"
            phx-click="close_modal"
          >
            &times;
          </span>
          <h2 class="text-2xl font-semibold mb-4">New Task</h2>
          <form phx-submit="commit_task" class="space-y-4">
            <input
              type="text"
              name="title"
              placeholder="Task Title"
              required
              class="w-full p-2 border border-gray-300 rounded"
            />
            <textarea
              name="content"
              placeholder="Task Content"
              required
              class="w-full p-2 border border-gray-300 rounded"
            ></textarea>
            <input
              type="number"
              name="priority"
              placeholder="Priority"
              required
              class="w-full p-2 border border-gray-300 rounded"
            />
            <input
              type="datetime-local"
              name="deadline"
              required
              class="w-full p-2 border border-gray-300 rounded"
            />
            <button
              type="submit"
              class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-full transition duration-200 ease-in-out"
            >
              Commit
            </button>
          </form>
        </div>
      </div>
    <% end %>
    """
  end

  @doc """
  Renders a list of tasks.
  """
  def task_list(assigns) do
    ~H"""
    <%= for task <- @tasks do %>
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
    <% end %>
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

  def project_list_item(assigns) do
    ~H"""
    <li>
      <span phx-click="select_project" phx-value-project_id={@project.id} class="flex-grow">
        <div class="flex items-center space-x-2 p-2 bg-white rounded-lg shadow-md hover:bg-gray-200 transition duration-200 ease-in-out">
          <span class="text-xl"><%= @project.icon %></span>
          <span class="font-semibold"><%= @project.title %></span>
          <span class="text-sm text-gray-500"><%= @project.status %></span>
        </div>
      </span>
    </li>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-1/4 p-4 bg-white shadow-lg fixed left-0 h-full">
        <div class="flex items-center mb-4">
          <img src={~p"/images/todo_logo.svg"} alt="Logo" class="h-8 w-8" />
          <span class="ml-2 text-xl font-bold">智能TODO</span>
        </div>
        <ul class="space-y-4">
          <%= for project <- @state.projects do %>
            <.project_list_item project={project} />
          <% end %>
        </ul>
        <button class="mt-4 w-full bg-purple-500 text-white py-2 rounded-lg">+ 添加新项目</button>
      </div>
      <div class="w-3/4 ml-1/4 p-4 fixed right-4">
        <.task_list tasks={@state.tasks} />
        <%= if @state.selected_project do %>
          <button
            phx-click="new_task"
            phx-value-project_id={@state.selected_project.id}
            class="mt-4 w-full bg-purpe bg-purple-500 text-white py-2 rounded-lg"
          >
            + 添加任务
          </button>
        <% end %>
      </div>
      <.task_form show={@state.new_task != nil} />
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    projects = Todos.list_projects_for_user(user)

    projects =
      case projects do
        [] ->
          {:ok, project} = Todos.create_default_project(user)
          [project | projects]

        _ ->
          projects
      end

    state = %__MODULE__{selected_project: nil, projects: projects, new_task: nil}

    socket
    |> assign(:state, state)
    |> then(&{:ok, &1})
  end

  # handle_event ...

  def handle_event("select_project", %{"project_id" => project_id}, socket) do
    projects = socket.assigns.state.projects
    project = Enum.find(projects, fn p -> to_string(p.id) == project_id end)

    tasks = Todos.list_tasks_by_project_id(project.id)
    Logger.info("select_project: #{inspect(project)} task=#{inspect(tasks)}")

    state = %{socket.assigns.state | selected_project: project, tasks: tasks}
    {:noreply, assign(socket, state: state)}
  end

  def handle_event("new_task", %{"project_id" => project_id}, socket) do
    projects = socket.assigns.state.projects
    project = Enum.find(projects, fn p -> to_string(p.id) == project_id end)

    state = %{
      socket.assigns.state
      | new_task: %{},
        selected_project: project
    }

    {:noreply, assign(socket, state: state)}
  end

  def handle_event(
        "commit_task",
        %{
          "title" => title,
          "content" => content,
          "priority" => priority,
          "deadline" => deadline
        },
        socket
      ) do
    project_id = socket.assigns.state.selected_project.id

    # 添加秒到 deadline 字符串
    # 例如 "2024-11-17T22:11:00"
    deadline_with_seconds = "#{deadline}:00.000Z"

    # 创建新任务
    case NaiveDateTime.from_iso8601(deadline_with_seconds) do
      {:ok, naive_datetime} ->
        {:ok, task} =
          Todos.create_task(%{
            title: title,
            content: content,
            priority: String.to_integer(priority),
            deadline: naive_datetime,
            project_id: project_id,
            user_id: socket.assigns.current_user.id
          })

        Logger.info("after create_task: #{inspect(task)}")
        # 更新任务列表
        tasks = Todos.list_tasks_by_project_id(project_id)

        state = %{socket.assigns.state | tasks: tasks, new_task: nil}

        socket
        |> info("Task created successfully")
        |> then(&{:noreply, assign(&1, state: state)})

      {:error, reason} ->
        # 处理错误，例如记录日志或返回错误消息
        Logger.error("Invalid deadline format: #{reason}")
        {:noreply, socket |> put_flash(:error, "Invalid deadline format.")}
    end
  end

  def handle_event("close_modal", _params, socket) do
    state = %{socket.assigns.state | new_task: nil}
    {:noreply, assign(socket, state: state)}
  end

  def handle_event("finish_task", %{"task_id" => task_id}, socket) do
    {:ok, task} =
      task_id
      |> Todos.get_task!()
      |> Todos.update_task(%{status: :completed})

    tasks =
      Enum.map(socket.assigns.state.tasks, fn t ->
        if t.id == task.id, do: task, else: t
      end)

    state = %{socket.assigns.state | tasks: tasks}
    {:noreply, assign(socket, state: state)}
  end

  def handle_event(event, _params, socket) do
    socket
    |> Phoenix.LiveView.put_flash(:error, "#{event}: Not implemented")
    |> then(&{:noreply, &1})
  end

  def info(socket, message) do
    socket
    |> Phoenix.LiveView.put_flash(:info, message)
  end
end
