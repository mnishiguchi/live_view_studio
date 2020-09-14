defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  @initial_brightness 10
  @initial_temperature 3000
  @min_brightness 0
  @max_brightness 100

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: @initial_brightness, temperature: @initial_temperature)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style="width: <%= @brightness %>%;
                     background-color: <%= temperature_color(@temperature) %>">
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

      <form phx-change="change-brightness">
        <input type="range" min="0" max="100"
               name="brightness" value="<%= @brightness %>" />
      </form>

      <form phx-change="change-temperature">
        <%= for temperature <- [3000, 4000, 5000] do %>
          <% temperature_id = "temperature_#{temperature}" %>
          <input type="radio" id="<%= temperature_id %>"
                 name="temperature" value="<%= temperature %>"
                 <%= if @temperature == temperature, do: "checked" %> />
          <label for="<%= temperature_id %>"><%= temperature %></label>
        <% end %>
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

  def handle_event("change-brightness", %{"brightness" => brightness}, socket) do
    brightness = String.to_integer(brightness)

    cond do
      brightness in @min_brightness..@max_brightness ->
        {:noreply, assign(socket, :brightness, brightness)}

      true ->
        {:noreply, socket}
    end
  end

  def handle_event("change-temperature", %{"temperature" => temperature}, socket) do
    temperature = String.to_integer(temperature)
    {:noreply, assign(socket, temperature: temperature)}
  end

  defp temperature_color(3000), do: "#F1C40D"
  defp temperature_color(4000), do: "#FEFF66"
  defp temperature_color(5000), do: "#99CCFF"
end
