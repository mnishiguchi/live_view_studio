defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  @initial_brightness 10
  @min_brightness 0
  @max_brightness 100

  def mount(_params, _session, socket) do
    socket = assign(socket, :brightness, @initial_brightness)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style="width:<%= @brightness %>%">
          <%= @brightness %>%
        </span>
      </div>

      <button phx-click="off">
        <img src="images/light-off.svg">
      </button>

      <button phx-click="down">
        <img src="images/down.svg">
      </button>

      <button phx-click="up">
        <img src="images/up.svg">
      </button>

      <button phx-click="on">
        <img src="images/light-on.svg">
      </button>

      <form phx-change="update">
        <input type="range" min="0" max="100"
               name="brightness" value="<%= @brightness %>" />
      </form>
    </div>
    """
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, @max_brightness)
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, fn prev -> min(prev + 10, @max_brightness) end)
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, fn prev -> max(prev - 10, @min_brightness) end)
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, @min_brightness)
    {:noreply, socket}
  end

  def handle_event("update", %{"brightness" => brightness}, socket) do
    brightness = String.to_integer(brightness)

    cond do
      brightness in @min_brightness..@max_brightness ->
        {:noreply, assign(socket, :brightness, brightness)}

      true ->
        {:noreply, socket}
    end
  end
end
