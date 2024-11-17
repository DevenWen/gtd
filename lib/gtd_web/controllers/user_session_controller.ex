defmodule GtdWeb.UserSessionController do
  use GtdWeb, :controller
  require Logger
  import Plug.Conn

  alias Gtd.Accounts
  alias GtdWeb.UserAuth

  @moduledoc """
  1. 接收 github 回调用
  """
  def new(conn, %{"provider" => "github", "code" => code, "state" => state}) do
    # 获取 github 账号信息
    client = github_client(conn)

    with {:ok, info} <- client.exchange_access_token(code: code, state: state),
         %{info: info, primary_email: primary, emails: emails, token: token} = info,
         {:ok, user} <- Accounts.register_github_user(primary, info, emails, token) do
      conn
      |> put_flash(:info, "Welcome #{user.email}")
      |> set_user_return_to(user)
      |> UserAuth.log_in_user(user)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.info("failed GitHub insert #{inspect(changeset.errors)}")

        conn
        |> put_flash(
          :error,
          "We were unable to fetch the necessary information from your GithHub account"
        )
        |> redirect(to: "/")

      {:error, reason} ->
        Logger.info("failed GitHub insert #{inspect(reason)}")

        conn
        |> put_flash(:error, "We were unable to contact GitHub. Please try again later")
        |> redirect(to: "/")
    end
  end

  @spec delete(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  defp set_user_return_to(conn, user) do
    user_main_path = ~p"/users/#{user.username}"
    put_session(conn, :user_return_to, user_main_path)
  end

  defp github_client(conn) do
    conn.assigns[:github_client] || Gtd.Github
  end
end
