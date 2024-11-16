defmodule Gtd.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Gtd.Repo

  alias Gtd.Accounts.{User, UserToken, UserNotifier, Identity}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, validate_email: false)
  end

  ## User registration

  @spec register_github_user(String.t(), map(), [map()], String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register_github_user(primary_email, info, emails, token) do
    if user = get_user_by_provider(:github, primary_email) do
      update_github_token(user, token)
    else
      # new account
      info
      |> User.github_registration_changeset(primary_email, emails, token)
      |> Repo.insert()
    end
  end

  def get_user_by_provider(provider, email) when provider in [:github] do
    query =
      from(u in User,
        join: i in assoc(u, :identities),
        where:
          i.provider == ^to_string(provider) and
            fragment("lower(?)", u.email) == ^String.downcase(email)
      )

    Repo.one(query)
  end

  def update_github_token(%User{} = user, new_token) do
    identity =
      Repo.one!(from(i in Identity, where: i.user_id == ^user.id and i.provider == "github"))

    {:ok, _} =
      identity
      |> change()
      |> put_change(:provider_token, new_token)
      |> Repo.update()

    {:ok, Repo.preload(user, :identities, force: true)}
  end

  ## Settings

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  # @doc ~S"""
  # Delivers the reset password email to the given user.

  # ## Examples

  #     iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
  #     {:ok, %{to: ..., body: ...}}

  # """
  # def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
  #     when is_function(reset_password_url_fun, 1) do
  #   {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
  #   Repo.insert!(user_token)
  #   UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  # end

  # @doc """
  # Gets the user by reset password token.

  # ## Examples

  #     iex> get_user_by_reset_password_token("validtoken")
  #     %User{}

  #     iex> get_user_by_reset_password_token("invalidtoken")
  #     nil

  # """
  # def get_user_by_reset_password_token(token) do
  #   with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
  #        %User{} = user <- Repo.one(query) do
  #     user
  #   else
  #     _ -> nil
  #   end
  # end

  # @doc """
  # Resets the user password.

  # ## Examples

  #     iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
  #     {:ok, %User{}}

  #     iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def reset_user_password(user, attrs) do
  #   Ecto.Multi.new()
  #   |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
  #   |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
  #   |> Repo.transaction()
  #   |> case do
  #     {:ok, %{user: user}} -> {:ok, user}
  #     {:error, :user, changeset, _} -> {:error, changeset}
  #   end
  # end

  ## API Authentication

  @doc """
  为用户创建新的 API token
  """
  def create_user_api_token(user) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "api-token")
    Repo.insert!(user_token)
    encoded_token
  end

  @doc """
  通过 API token 获取用户
  """
  def fetch_user_by_api_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "api-token"),
         %User{} = user <- Repo.one(query) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  def delete_user_api_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "api-token"))
    :ok
  end
end
