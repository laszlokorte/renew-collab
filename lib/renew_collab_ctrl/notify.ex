defmodule RenewCollabCtrl.Notify do
  def subscribe_to({:all, :projects}) do
  end

  def subscribe_to({:all, :documents}) do
  end

  def subscribe_to({:all, :simulations}) do
  end

  def subscribe_to({:all, :shadow_net_systems}) do
  end

  def subscribe_to({:all, :accounts}) do
  end

  def subscribe_to({:all, :socket_schemas}) do
  end

  def subscribe_to({:all, :icons}) do
  end

  def subscribe_to({:all, :syntax}) do
  end

  def subscribe_to({:all, :primitives}) do
  end

  def subscribe_to({{:account, account_id}, :self}) do
  end

  def subscribe_to({{:account, account_id}, :projects}) do
  end

  def subscribe_to({{:account, account_id}, :documents}) do
  end

  def subscribe_to({{:account, account_id}, :simulations}) do
  end

  def subscribe_to({{:account, account_id}, :shadow_net_systems}) do
  end

  def subscribe_to({{:project, project_id}, :self}) do
  end

  def subscribe_to({{:project, project_id}, :documents}) do
  end

  def subscribe_to({{:project, project_id}, :documents}) do
  end

  def subscribe_to({{:project, project_id}, :simulations}) do
  end

  def subscribe_to({{:project, project_id}, :shadow_net_systems}) do
  end

  def subscribe_to({{:document, document_id}, :self}) do
  end

  def subscribe_to({{:simulation, simulation_id}, :self}) do
  end

  def subscribe_to({{:shadow_net_system, sns_id}, :self}) do
  end

  def subscribe_to({{:shadow_net_system, sns_id}, :simulations}) do
  end
end
