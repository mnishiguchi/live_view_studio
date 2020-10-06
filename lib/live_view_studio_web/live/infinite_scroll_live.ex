defmodule LiveViewStudioWeb.InfiniteScrollLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page: 1, per_page: 10)
      |> load_orders()

    {:ok, socket, temporary_assigns: [orders: []]}
  end

  defp load_orders(socket) do
    assign(socket,
      orders:
        PizzaOrders.list_pizza_orders(
          page: socket.assigns.page,
          per_page: socket.assigns.per_page
        )
    )
  end

  def handle_event("load-more", _, socket) do
    socket =
      socket
      |> update(:page, &(&1 + 1))
      |> load_orders()

    {:noreply, socket}
  end
end
