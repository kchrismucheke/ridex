defmodule RidexWeb.PageController do
  use RidexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
