defmodule GtdWeb.UserTodosLive do
  use GtdWeb, :live_view
  alias Gtd.Todos
  require Logger

  defstruct selected_project: nil, projects: [], tasks: [], new_task: %{}

  def project_list_item(assigns) do
    ~H"""
    <li class="flex items-center py-2 px-4 cursor-pointer hover:bg-gray-300 hover:shadow-md transition duration-200 ease-in-out">
      <span phx-click="select_project" phx-value-project_id={@project.id} class="flex-grow">
        <%= @project.title %>
      </span>
      <button
        phx-click="new_task"
        phx-value-project_id={@project.id}
        class="ml-5 text-white font-bold py-1 px-2 rounded transition duration-200 ease-in-out"
      >
        ➕
      </button>
    </li>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-1/3 p-4 border-r bg-gray-100 rounded-lg shadow-lg">
        <h2 class="text-2xl font-bold text-gray-900"><%= @current_user.name %></h2>
        <h3 class="mt-4 text-lg font-medium text-gray-700">Projects</h3>
        <ul class="mt-2 space-y-2">
          <%= for project <- @state.projects do %>
            <.project_list_item project={project} />
          <% end %>
        </ul>
      </div>
      <div class="w-2/3 p-4">
        <.task_list tasks={@state.tasks} />
      </div>
      <.task_form show={@state.new_task} />
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
