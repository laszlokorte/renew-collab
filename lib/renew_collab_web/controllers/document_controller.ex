defmodule RenewCollabWeb.DocumentController do
  use RenewCollabWeb, :controller

  alias RenewCollab.Renew
  alias RenewCollab.Document.Document
  alias RenewCollab.Element.Element

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    documents = Renew.list_documents()
    render(conn, :index, documents: documents)
  end

  def create(conn, %{"document" => document_params}) do
    with {:ok, %Document{} = document} <- Renew.create_document(document_params) do
      RenewCollabWeb.Endpoint.broadcast!(
        "documents",
        "document:new",
        Map.take(document, [:name, :kind, :id])
        |> Map.put("href", url(~p"/api/documents/#{document}"))
      )

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/documents/#{document}")
      |> render(:show, document: document)
    end
  end

  def show(conn, %{"id" => id}) do
    document = Renew.get_document_with_elements!(id)
    render(conn, :show, document: document)
  end

  def update(conn, %{"id" => id, "document" => document_params}) do
    document = Renew.get_document!(id)

    with {:ok, %Document{} = document} <- Renew.update_document(document, document_params) do
      render(conn, :show, document: document)
    end
  end

  def delete(conn, %{"id" => id}) do
    document = Renew.get_document!(id)

    with {:ok, %Document{}} <- Renew.delete_document(document) do
      RenewCollabWeb.Endpoint.broadcast!(
        "documents",
        "document:delete",
        Map.take(document, [:id])
        |> Map.put("href", url(~p"/api/documents/#{id}"))
      )

      send_resp(conn, :no_content, "")
    end
  end

  defp convert_color(m) when is_binary(m), do: m
  defp convert_color({:rgba, r, g, b, a}), do: "rgba(#{r},#{g},#{b},#{a})"
  defp convert_color({:rgb, r, g, b}), do: "rgb(#{r},#{g},#{b})"

  defp convert_alignment("left"), do: :left
  defp convert_alignment("center"), do: :center
  defp convert_alignment("right"), do: :right
  defp convert_alignment(_), do: :left

  def import(conn, %{
        "renew_file" => %Plug.Upload{
          path: path,
          content_type: content_type,
          filename: filename
        }
      }) do
    with {:ok, content} <- File.read(path),
         {:ok, true} <- check_utf8_binary?(content),
         {:ok, document, refs} <- Renewex.parse_string(content),
         %Renewex.Storable{class_name: class_name, fields: %{figures: figures}} <- document do
      figs =
        figures |> Enum.map(&Enum.at(refs, elem(&1, 1))) |> Enum.with_index() |> Enum.to_list()

      # FrameColor
      # FillColor
      # TextColor
      # TextAlignment
      # ArrowMode
      # FontName
      # LineWidth
      # LineStyle
      # FontSize
      # FontStyle
      # LineShape
      # BSplineSegments
      # BSplineDegree
      # ArcScale
      elements =
        Enum.concat([
          for {%Renewex.Storable{fields: %{x: x, y: y, w: w, h: h} = fields}, z_index} <- figs do
            attrs =
              with %Renewex.Storable{fields: f} <- Map.get(fields, :attributes) do
                f.attributes |> Enum.into(%{}, fn {key, _type, value} -> {key, value} end)
              else
                _ -> nil
              end

            style =
              case attrs do
                nil ->
                  nil

                attrs ->
                  %{
                    "opacity" => Map.get(attrs, "Opacity", 1),
                    "background_color" => convert_color(Map.get(attrs, "FillColor", "green")),
                    "border_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                    "border_width" => Map.get(attrs, "LineWidth", "1")
                  }
              end

            %{
              "position_x" => x,
              "position_y" => y,
              "z_index" => z_index,
              "box" => %{"width" => w, "height" => h},
              "style" => style
            }
          end,
          for {%Renewex.Storable{fields: %{text: body, fOriginX: x, fOriginY: y} = fields},
               z_index} <-
                figs do
            attrs =
              with %Renewex.Storable{fields: f} <- Map.get(fields, :attributes) do
                f.attributes |> Enum.into(%{}, fn {key, _type, value} -> {key, value} end)
              else
                _ -> nil
              end

            style =
              case attrs do
                nil ->
                  nil

                attrs ->
                  %{
                    "opacity" => Map.get(attrs, "Opacity", 1),
                    "background_color" => convert_color(Map.get(attrs, "FillColor", "green")),
                    "border_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                    "border_width" => Map.get(attrs, "LineWidth", "1")
                  }
              end

            %{
              "position_x" => x,
              "position_y" => y,
              "z_index" => z_index,
              "text" => %{
                "body" => body,
                "style" => %{
                  "italic" => Map.get(attrs, :fCurrentFontStyle, 0) == 1,
                  "underline" => false,
                  "alignment" => convert_alignment(Map.get(attrs, "TextAlignment", "left")),
                  "font_size" => Map.get(attrs, :fCurrentFontSize, 12),
                  "font_family" => Map.get(attrs, :fCurrentFontName, "Sans Serif"),
                  "bold" => Map.get(attrs, :fCurrentFontStyle, 0) == 2,
                  "text_color" => convert_color(Map.get(attrs, "TextColor", "black"))
                }
              }
            }
          end,
          for {%Renewex.Storable{fields: %{points: [_, _ | _] = points} = fields}, z_index} <-
                figs do
            start_point = hd(points)
            end_point = List.last(points)
            start_x = start_point[:x]
            start_y = start_point[:y]
            end_x = end_point[:x]
            end_y = end_point[:y]

            attrs =
              with %Renewex.Storable{fields: f} <- Map.get(fields, :attributes) do
                f.attributes |> Enum.into(%{}, fn {key, _type, value} -> {key, value} end)
              else
                _ -> nil
              end

            style =
              case attrs do
                nil ->
                  nil

                attrs ->
                  %{
                    "opacity" => Map.get(attrs, "Opacity", 1)
                  }
              end

            line_style =
              case attrs do
                nil ->
                  nil

                attrs ->
                  %{
                    "stroke_width" => Map.get(attrs, "LineWidth", "1"),
                    "stroke_color" => convert_color(Map.get(attrs, "FrameColor", "black")),
                    "stroke_joint" => "round",
                    "stroke_cap" => "round",
                    "stroke_dash_array" => "",
                    "source_tip" => "",
                    "target_tip" => "",
                    "smoothness" => ""
                  }
              end

            %{
              "position_x" => (start_x + end_x) / 2,
              "position_y" => (start_y + end_y) / 2,
              "z_index" => z_index,
              "style" => style,
              "connection" => %{
                "source_x" => start_x,
                "source_y" => start_y,
                "target_x" => end_x,
                "target_y" => end_y,
                "waypoints" =>
                  points
                  |> Enum.drop(1)
                  |> Enum.drop(-1)
                  |> Enum.with_index()
                  |> Enum.map(fn {p, index} ->
                    %{
                      "sort" => index,
                      "position_x" => p[:x],
                      "position_y" => p[:y]
                    }
                  end),
                "style" => line_style
              }
            }
          end
        ])

      document =
        create(conn, %{
          "document" => %{"name" => filename, "kind" => class_name, "elements" => elements}
        })

      document
    else
      e ->
        conn
        |> put_status(:bad_request)
        |> Phoenix.Controller.json(%{"error" => "Not a valid renew file"})
        |> halt()
    end
  end

  defp check_utf8_binary?(binary) do
    if :unicode.characters_to_binary(binary, :utf8, :utf8) == binary do
      {:ok, true}
    else
      {:ok, false}
    end
  end
end
