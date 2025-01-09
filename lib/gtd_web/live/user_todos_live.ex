defmodule GtdWeb.UserTodosLive do
  use GtdWeb, :live_view
  alias Gtd.Todos

  alias GtdWeb.{
    ProjectListItemComponent,
    ProjectFormComponent,
    TaskListComponent,
    TaskFormComponent
  }

  require Logger

  defstruct selected_project: nil, projects: [], tasks: [], new_task: false, new_project: false

  @impl true
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

    state = %__MODULE__{
      selected_project: nil,
      projects: projects,
      new_task: false,
      new_project: false
    }

    {:ok, assign(socket, :state, state)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="w-1/4 p-4 bg-white shadow-lg fixed left-0 h-full">
        <div class="flex items-center mb-4">
          <img src={~p"/images/todo_logo.svg"} alt="Logo" class="h-8 w-8" />
          <span class="ml-2 text-xl font-bold">智能TODO</span>
        </div>
        <ul class="space-y-4">
          <div :for={project <- @state.projects}>
            <.live_component
              module={ProjectListItemComponent}
              id={"project-#{project.id}"}
              project={project}
            />
          </div>
          <.live_component module={ProjectFormComponent} id="project-form" show={@state.new_project} />
        </ul>
        <button phx-click="new_project" class="mt-4 w-full gtd-button">
          + 添加新项目
        </button>
      </div>
      <div class="w-3/4 ml-1/4 p-4 fixed right-4">
        <.live_component
          module={TaskListComponent}
          id="task-list"
          tasks={@state.tasks}
          new_task?={@state.new_task}
          project={@state.selected_project}
        />
      </div>
      <%!-- <.live_component module={TaskFormComponent} id="task-form" show={@state.new_task} /> --%>
    </div>
    """
  end

  @impl true
  def handle_event("new_project", _params, socket) do
    state = %{socket.assigns.state | new_project: true}
    {:noreply, assign(socket, :state, state)}
  end

  @impl true
  def handle_event("select_project", %{"project_id" => project_id}, socket) do
    project = Enum.find(socket.assigns.state.projects, fn p -> to_string(p.id) == project_id end)
    tasks = Todos.list_tasks_by_project_id(project.id)
    Logger.info("选中项目: #{inspect(project)} 任务: #{inspect(tasks)}")

    state = %{socket.assigns.state | selected_project: project, tasks: tasks}
    {:noreply, assign(socket, :state, state)}
  end

  @impl true
  def handle_info({:commit_project, %{icon: icon, title: title}}, socket) do
    {:ok, _project} =
      Todos.create_project(%{icon: icon, title: title, user_id: socket.assigns.current_user.id})

    projects = Todos.list_projects_for_user(socket.assigns.current_user)
    state = %{socket.assigns.state | projects: projects, new_project: false}
    {:noreply, assign(socket, :state, state)}
  end

  @impl true
  def handle_info({:commit_task, params}, socket) do
    project_id = socket.assigns.state.selected_project.id
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
        tasks = Todos.list_tasks_by_project_id(project_id)
        state = %{socket.assigns.state | tasks: tasks, new_task: nil}
        {:noreply, assign(socket, :state, state)}

      {:error, reason} ->
        Logger.error("无效的截止日期格式: #{reason}")
        {:noreply, put_flash(socket, :error, "无效的截止日期格式。")}
    end
  end

  @impl true
  def handle_info(:close_modal, socket) do
    state = %{socket.assigns.state | new_project: false, new_task: false}
    send_update(TaskListComponent, id: "task-list", show?: false)
    {:noreply, assign(socket, :state, state)}
  end

  @impl true
  def handle_info({:finish_task, task_id}, socket) do
    {:ok, task} =
      task_id
      |> Todos.get_task!()
      |> Todos.update_task(%{status: :completed})

    tasks =
      Enum.map(socket.assigns.state.tasks, fn t ->
        if t.id == task.id, do: task, else: t
      end)

    state = %{socket.assigns.state | tasks: tasks}
    {:noreply, assign(socket, :state, state)}
  end

  @impl true
  def handle_event(event, _params, socket) do
    socket
    |> Phoenix.LiveView.put_flash(:error, "#{event}: 未实现")
    |> then(&{:noreply, &1})
  end
end
