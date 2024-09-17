defmodule RenewCollab.Import.Converted do
  defstruct [
    :name,
    :kind,
    :layers,
    :hierarchy,
    :annotation_links
  ]

  def new(
        name,
        kind,
        layers,
        hierarchy,
        annotation_links
      ) do
    %RenewCollab.Import.Converted{
      name: name,
      kind: kind,
      layers: layers,
      hierarchy: hierarchy,
      annotation_links: annotation_links
    }
  end
end
