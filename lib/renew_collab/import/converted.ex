defmodule RenewCollab.Import.Converted do
  defstruct [
    :name,
    :kind,
    :layers,
    :hierarchy,
    :hyperlinks,
    :bonds
  ]

  def new(
        name,
        kind,
        layers,
        hierarchy,
        hyperlinks,
        bonds
      ) do
    %RenewCollab.Import.Converted{
      name: name,
      kind: kind,
      layers: layers,
      hierarchy: hierarchy,
      hyperlinks: hyperlinks,
      bonds: bonds
    }
  end
end
