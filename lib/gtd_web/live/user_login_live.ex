defmodule GtdWeb.UserLoginLive do
  use GtdWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center">
      <div class="bg-white shadow-md rounded-lg p-8 max-w-lg w-full">
        <div class="flex justify-center mb-6">
          <img src={~p"/images/todo_logo.svg"} alt="Logo" class="h-10 w-10" />
          <span class="ml-2 text-xl font-bold">智能TODO助手</span>
        </div>
        <div class="text-center mb-6">
          <h2 class="text-2xl font-semibold">欢迎使用</h2>
          <p class="text-gray-600">使用GitHub账号登录以开始管理您的任务</p>
        </div>
        <div class="text-center">
          <.link
            href={Gtd.Github.authorize_url()}
            class="text-sm font-semibold inline-flex items-center"
          >
            <img src={~p"/images/github-mark.svg"} alt="Github Logo" class="h-6 w-6 mr-2" />
            使用GitHub登录
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
