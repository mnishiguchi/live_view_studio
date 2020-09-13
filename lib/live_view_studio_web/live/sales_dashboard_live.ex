defmodule LiveViewStudioWeb.SalesDashboardLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Sales

  @initial_refresh_interval 1

  def mount(_params, _session, socket) do
    # Initialize socket assigns.
    socket =
      socket
      |> assign_stats()
      |> assign(refresh_interval: @initial_refresh_interval)
      |> assign(last_updated_at: Timex.now())

    # Mount is invoked twice, once for the initial HTTP request that returns a
    # full HTML page. And again when the client has connected to the WebSocket.
    # So we need to wait until it's in this connected state before sending the
    # message.
    if connected?(socket) do
      schedule_refresh(socket)
    end

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

      <form phx-change="refresh">
        <label for="refresh_interval">
          Refresh every:
        </label>
        <select name="refresh_interval">
          <%= options_for_select(refresh_interval_options(), @refresh_interval) %>
        </select>
      </form>

      <div>
      Last updated at:
      <%= Timex.format!(@last_updated_at, "%H:%M:%S", :strftime) %>
      </div>
    </div>
    """
  end

  @doc """
  Invoked when the refresh interval is selected. Updates the value for
  `refresh_interval`.
  """
  def handle_event("refresh", %{"refresh_interval" => refresh_interval}, socket) do
    refresh_interval = String.to_integer(refresh_interval)
    socket = assign(socket, refresh_interval: refresh_interval)

    {:noreply, socket}
  end

  @doc """
  Refreshes stats and schedules next refresh.
  """
  def handle_info(:tick, socket) do
    socket = socket |> assign_stats |> assign(last_updated_at: Timex.now())
    schedule_refresh(socket)

    {:noreply, socket}
  end

  # Re-calculates stats and assigns it to the socket.
  defp assign_stats(%{assigns: %{}} = socket) do
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.satisfaction()
    )
  end

  # Schedules refresh with the currently-set refresh interval.
  defp schedule_refresh(%{assigns: %{refresh_interval: refresh_interval}}) do
    milliseconds = refresh_interval * 1000
    Process.send_after(self(), :tick, milliseconds)
  end

  # A list of lable-value pair tuples for the refresh interval options.
  defp refresh_interval_options do
    Enum.map([1, 5, 15, 30, 60], fn x -> {"#{x}s", x} end)
  end
end
