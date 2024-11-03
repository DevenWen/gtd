defmodule GtdWeb.Api.TokenController do
  use GtdWeb, :controller
  alias Gtd.Accounts
  alias GtdWeb.UserAuth

  def create(conn, %{"email" => email, "password" => password}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      token = Accounts.create_user_api_token(user)

      conn
      |> put_status(:created)
      |> json(%{
        data: %{
          token: token,
          user: %{
            id: user.id,
            email: user.email
          }
        }
      })
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid email or password"})
    end
  end

  def delete(conn, _param) do
    UserAuth.log_out_for_api(conn)
  end

  def get_session(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> put_resp_content_type("application/json")
    |> json(%{message: "authenticated", user_email: user.email})
  end
end
