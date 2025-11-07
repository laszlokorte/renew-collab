defmodule RenewCollabWeb.InvitationJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{invitations: invitations}) do
    %{
      href: url(~p"/api/invitations"),
      topic: "my-invitations",
      content: index_content(%{invitations: invitations}),
      links: %{}
    }
  end

  def index_content(%{invitations: invitations}) do
    %{
      items:
        for i <- invitations do
          %{id: i.id, project_id: i.project_id, project_name: i.project.name, role: i.role}
        end
    }
  end
end
