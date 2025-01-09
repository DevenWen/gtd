# lib/gtd_web/live/components/project_form_component.ex
defmodule GtdWeb.ProjectFormComponent do
  use GtdWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@show} class="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
        <div class="bg-white p-6 rounded-lg shadow-lg w-1/2 relative">
          <button
            phx-click="close"
            phx-target={@myself}
            class="absolute top-2 right-2 text-gray-500 hover:text-gray-700"
          >
            &times;
          </button>
          <h2 class="text-2xl font-semibold mb-4">创建新项目</h2>
          <form phx-submit="commit_project" phx-target={@myself} class="space-y-4">
            <div class="flex space-x-2">
              <input
                type="text"
                name="icon"
                placeholder="图标"
                required
                class="w-12 p-2 border border-gray-300 rounded"
              />
              <input
                type="text"
                name="title"
                placeholder="项目标题"
                required
                class="flex-1 p-2 border border-gray-300 rounded"
              />
            </div>

            <button type="submit" class="gtd-button">
              新增
            </button>
          </form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("commit_project", params, socket) do
    send(self(), {:commit_project, params})
    {:noreply, socket}
  end

  @impl true
  def handle_event("close", _params, socket) do
    send(self(), :close_modal)
    {:noreply, socket}
  end
end
