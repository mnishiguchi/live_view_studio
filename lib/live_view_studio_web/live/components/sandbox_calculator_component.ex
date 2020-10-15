defmodule LiveViewStudioWeb.SandboxCalculatorComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.SandboxCalculator

  @default_assigns [
    length: nil,
    width: nil,
    depth: nil,
    color: nil,
    weight: 0
  ]

  def mount(socket) do
    {:ok,
     socket
     |> assign(@default_assigns)}
  end

  # Invoked everytime the quote form is changed.
  def handle_event("calculate_quote", %{"length" => l, "width" => w, "depth" => d, "color" => color} = _params, socket) do
    dimensions = [length: l, width: w, depth: d]

    {:noreply,
     socket
     |> assign(dimensions)
     |> assign(
       color: color,
       weight: SandboxCalculator.calculate_weight(dimensions)
     )}
  end

  # Involked when the quote form is submitted.
  def handle_event("get_quote", _params, %{assigns: %{weight: weight, color: color}} = socket) do
    price = SandboxCalculator.calculate_price_from_weight(weight)

    # `self` is the process in which the parent LiveView and the components are
    # running. The parent LiveView will receive and handle this message.
    send(self(), {:totals, weight, price, color})

    {:noreply, socket}
  end
end
