defmodule RenewCollab.Import.Converted do
  defstruct [
    :name,
    :kind,
    :layers,
    :hierarchy,
    :hyperlinks
  ]

  def new(
        name,
        kind,
        layers,
        hierarchy,
        hyperlinks
      ) do
    %RenewCollab.Import.Converted{
      name: name,
      kind: kind,
      layers: layers,
      hierarchy: hierarchy,
      hyperlinks: hyperlinks
    }
  end
end
