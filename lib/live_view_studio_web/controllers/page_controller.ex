defmodule LiveViewStudioWeb.PageController do
  use LiveViewStudioWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
