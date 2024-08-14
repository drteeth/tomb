defmodule TombWeb.PageController do
  use TombWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
