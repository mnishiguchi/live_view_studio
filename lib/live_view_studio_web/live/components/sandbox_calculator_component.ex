defmodule LiveViewStudioWeb.SandboxCalculatorComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.SandboxCalculator

  # Useful when we we want to assign default values.
  def mount(socket) do
    {:ok,
     socket
     |> assign(
       length: nil,
       width: nil,
       depth: nil,
       weight: 0
     )}
  end

  # Invoked everytime the quote form is changed.
  def handle_event("calculate_quote", %{"length" => l, "width" => w, "depth" => d} = _params, socket) do
    dimensions = [length: l, width: w, depth: d]

    {:noreply,
     socket
     |> assign(dimensions)
     |> assign(weight: SandboxCalculator.calculate_weight(dimensions))}
  end

  # Involked when the quote form is submitted.
  def handle_event("get_quote", _params, %{assigns: %{weight: weight}} = socket) do
    price = SandboxCalculator.calculate_price_from_weight(weight)

    # `self` is the process in which the parent LiveView and the components are
    # running. The parent LiveView will receive and handle this message.
    send(self(), {:totals, weight, price})

    {:noreply, socket}
  end
end
