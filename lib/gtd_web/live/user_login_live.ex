defmodule GtdWeb.UserLoginLive do
  use GtdWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <:actions>
          <.link href={Gtd.Github.authorize_url()} class="text-sm font-semibold">
            <img src={~p"/images/github-mark.svg"} alt="Github Logo" class="h-6 w-6 inline-block" />
            Login with Github
          </.link>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
