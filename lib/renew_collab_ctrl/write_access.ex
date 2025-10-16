defmodule RenewCollabCtrl.WriteAccess do
  def can(_account, _action), do: false
end
