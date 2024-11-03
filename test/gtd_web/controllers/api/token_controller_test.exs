defmodule GtdWeb.Api.TokenControllerTest do
  use ExUnit.Case
  doctest GtdWeb.Api.TokenController
  use GtdWeb.ConnCase
  import Gtd.AccountsFixtures

  setup %{conn: conn} do
    user = user_fixture()
    token = create_user_api_token(user)
    %{conn: conn, user: user, token: token}
  end

  describe "POST /api/token" do
    test "returns token when credentials are valid", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/token", %{
          "email" => user.email,
          "password" => valid_user_password()
        })

      response = json_response(conn, 201)

      assert %{
               "data" => %{
                 "token" => token,
                 "user" => %{
                   "id" => user_id,
                   "email" => email
                 }
               }
             } = response

      assert is_binary(token)
      assert user_id == user.id
      assert email == user.email
    end

    test "returns error when credentials are invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/token", %{
          "email" => "invalid@example.com",
          "password" => "invalid"
        })

      assert json_response(conn, 401) == %{
               "error" => "Invalid email or password"
             }
    end

    test "returns error when token is invalid", %{conn: conn} do
      conn = get(conn, ~p"/api/token")

      assert json_response(conn, 401) == %{
               "error" => "未授权访问"
             }
    end

    test "returns user email when token is valid", %{conn: conn, user: user, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/token")

      assert json_response(conn, 200) == %{
               "message" => "authenticated",
               "user_email" => user.email
             }
    end
  end

  describe "DELETE /api/token" do
    test "logs out user", %{conn: conn, token: token} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> delete(~p"/api/token")

      assert response(conn, 204)
    end
  end
end
