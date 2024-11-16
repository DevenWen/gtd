defmodule GtdWeb.UserHTML do
  @moduledoc """
  This module contains pages rendered by UserController.

  See the `user_html` directory for all templates available.
  """
  use GtdWeb, :html

  embed_templates "page_html/*"
end
