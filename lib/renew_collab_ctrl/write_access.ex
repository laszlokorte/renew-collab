defmodule RenewCollabCtrl.WriteAccess do
  alias RenewCollabCtrl.Actions
  def can(account, action)
  def can(_account, %Actions.DocumentEditLayerTextSizeHint{}), do: true
  def can(_account, %Actions.DocumentEditSetThumbnail{}), do: true
  def can(_account, %Actions.DocumentEditRemoveThumbnail{}), do: true
  def can(_account, %Actions.DocumentCreateInProject{}), do: true
  def can(_account, _action), do: false
end
