defmodule LiveViewStudioWeb.DatePickerLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, date: nil)}
  end

  def handle_event("date_picker:picked", %{"date" => date}, socket) when is_binary(date) do
    {:noreply, assign(socket, date: date)}
  end
end
