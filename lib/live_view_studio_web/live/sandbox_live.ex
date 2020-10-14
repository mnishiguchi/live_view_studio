defmodule LiveViewStudioWeb.SandboxLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.{QuoteComponent, SandboxCalculatorComponent}

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(weight: nil, price: nil)}
  end

  def handle_info({:totals, weight, price}, socket) do
    {:noreply,
     socket
     |> assign(weight: weight, price: price)}
  end
end
