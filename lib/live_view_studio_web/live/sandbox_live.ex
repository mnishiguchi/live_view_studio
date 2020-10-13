defmodule LiveViewStudioWeb.SandboxLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.QuoteComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

end
