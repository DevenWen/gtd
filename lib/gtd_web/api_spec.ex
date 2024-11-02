defmodule GtdWeb.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  alias GtdWeb.{Endpoint, Router}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "GTD API",
        version: to_string(Application.spec(:gtd, :vsn)),
        description: to_string(Application.spec(:gtd, :description))
      },
      paths: Paths.from_router(Router)
    }
    # 解析所有模式模块
    |> OpenApiSpex.resolve_schema_modules()
  end
end
