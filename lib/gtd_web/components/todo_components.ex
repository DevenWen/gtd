defmodule GtdWeb.TodoComponents do
  use Phoenix.Component

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
    <ul class="mt-2 space-y-2">
      <%= for task <- @tasks do %>
        <div>
          <li class="py-2 px-4 bg-gray-50 rounded-lg shadow-sm hover:shadow-md transition duration-200 ease-in-out flex justify-between items-center">
            <div>
              <h3 class="text-lg font-bold"><%= task.title %></h3>
              <p class="text-gray-700"><%= task.content %></p>
              <p class="text-sm text-gray-500">优先级: <%= task.priority %></p>
              <p class="text-sm text-gray-500">截止日期: <%= task.deadline %></p>
            </div>
            <div class="font-bold py-2 px-4 rounded-full transition duration-200 ease-in-out">
              <%= if task.status != :completed do %>
                <button phx-click="finish_task" phx-value-task_id={task.id}>
                  <%= task_status(task.status) %>
                </button>
              <% else %>
                <span><%= task_status(task.status) %></span>
              <% end %>
            </div>
          </li>
        </div>
      <% end %>
    </ul>
    """
  end

  defp task_status(status) do
    case status do
      :completed -> "✔️"
      :in_progress -> "✊"
      _ -> "⌛️"
    end
  end
end
