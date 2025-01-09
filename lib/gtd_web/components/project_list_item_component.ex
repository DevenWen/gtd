# lib/gtd_web/live/components/project_list_item_component.ex
defmodule GtdWeb.ProjectListItemComponent do
  use GtdWeb, :live_component

  @impl true
  def render(assigns) do
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

  @impl true
  def handle_event("select_project", %{"project_id" => project_id}, socket) do
    send(self(), {:select_project, project_id})
    {:noreply, socket}
  end
end
