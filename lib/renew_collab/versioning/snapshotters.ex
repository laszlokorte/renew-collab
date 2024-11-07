defmodule RenewCollab.Versioning.Snapshotters do
  @snapshotters [
    RenewCollab.Hierarchy.Layer.Snapshotter,
    RenewCollab.Hierarchy.LayerParenthood.Snapshotter,
    RenewCollab.Element.Box.Snapshotter,
    RenewCollab.Element.Text.Snapshotter,
    RenewCollab.Element.Edge.Snapshotter,
    RenewCollab.Element.Interface.Snapshotter,
    RenewCollab.Style.LayerStyle.Snapshotter,
    RenewCollab.Style.EdgeStyle.Snapshotter,
    RenewCollab.Style.TextStyle.Snapshotter,
    RenewCollab.Style.TextSizeHint.Snapshotter,
    RenewCollab.Connection.Waypoint.Snapshotter,
    RenewCollab.Connection.WaypointTangent.Snapshotter,
    RenewCollab.Connection.Hyperlink.Snapshotter,
    RenewCollab.Connection.Bond.Snapshotter
  ]

  def snapshotters() do
    @snapshotters
  end
end
