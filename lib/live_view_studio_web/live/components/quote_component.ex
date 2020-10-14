# Most stateless components only need the render function.
defmodule LiveViewStudioWeb.QuoteComponent do
  use LiveViewStudioWeb, :live_component

  import Number.Currency

  def mount(socket) do
    {:ok, assign(socket, hrs_until_expires: 24)}
  end

  # Useful when we want to derive assigns from the passed-in assigns.
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(minutes: socket.assigns.hrs_until_expires * 60)}
  end
end
