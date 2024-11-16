defmodule GtdWeb.UserController do
  use GtdWeb, :controller

  def show(conn, _params) do
    user = conn.assigns.current_user
    render(conn, :user, user: user)
  end
end
