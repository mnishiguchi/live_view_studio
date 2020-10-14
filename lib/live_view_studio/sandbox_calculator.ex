defmodule LiveViewStudio.SandboxCalculator do
  def calculate_weight(length: l, width: w, depth: d) do
    l = to_integer(l)
    w = to_integer(w)
    d = to_integer(d)

    (l * w * d * 7.3) |> Float.round(2)
  end

  def calculate_price_from_weight(weight) do
    weight * 1.5
  end

  defp to_integer(param) do
    case Integer.parse(param) do
      {value, ""} ->
        value

      :error ->
        0
    end
  end
end
