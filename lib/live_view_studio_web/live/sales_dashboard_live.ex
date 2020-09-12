defmodule LiveViewStudioWeb.SalesDashboardLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Sales

  def mount(_params, _session, socket) do
    # Mount is invoked twice, once for the initial HTTP request that returns a
    # full HTML page. And again when the client has connected to the WebSocket.
    # So we need to wait until it's in this connected state before sending the
    # message.
    if connected?(socket) do
      # After connected, self is a LiveView process. :tick is an internal
      # message.
      :timer.send_interval(1000, self(), :tick)
    end

    socket = assign_stats(socket)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Sales Dashboard</h1>

    <div id="dashboard">
      <div class="stats">
        <div class="stat">
          <span class="value">
            <%= @new_orders %>
          </span>
          <span class="name">
            New Orders
          </span>
        </div>

        <div class="stat">
          <span class="value">
            $<%= @sales_amount %>
          </span>
          <span class="name">
            Sales Amount
          </span>
        </div>

        <div class="stat">
          <span class="value">
            <%= @satisfaction %>%
          </span>
          <span class="name">
            Satisfaction
          </span>
        </div>
      </div>

      <button phx-click="refresh">
        <img src="images/refresh.svg">
        Refresh
      </button>
    </div>
    """
  end

  @doc """
  Handles the browser event "refresh".
  """
  def handle_event("refresh", _, socket) do
    socket = assign_stats(socket)
    {:noreply, socket}
  end

  @doc """
  Handles the internal message :tick.
  """
  def handle_info(:tick, socket) do
    socket = assign_stats(socket)
    {:noreply, socket}
  end

  defp assign_stats(socket) do
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.satisfaction()
    )
  end
end
