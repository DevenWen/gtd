defmodule GtdWeb.DemoLive do
  use GtdWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :counter, 0)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Counter: <%= @counter %></h1>
      <button phx-click="increase">Increase</button>
      <button phx-click="decrease">Decrease</button>
    </div>
    """
  end

  def handle_event("increase", _params, socket) do
    {:noreply, update(socket, :counter, &(&1 + 1))}
  end

  def handle_event("decrease", _params, socket) do
    {:noreply, update(socket, :counter, &(&1 - 1))}
  end
end
