defmodule LiveViewStudioWeb.SandboxLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.{QuoteComponent, SandboxCalculatorComponent}

  @default_assigns [
    weight: nil,
    price: nil,
    color: "indigo"
  ]

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(@default_assigns)}
  end

  def handle_info({:totals, weight, price, color}, socket) do
    {:noreply,
     socket
     |> assign(
       weight: weight,
       price: price,
       color: color
     )}
  end
end
