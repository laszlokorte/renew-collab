defmodule RenewCollabWeb.ThumbnailSVG do
  use RenewCollabWeb, :html

  embed_templates "thumbnail_html/*"

  def background(%{style: %{background_color: col}}), do: col
  def background(_layer), do: "gray"
end
