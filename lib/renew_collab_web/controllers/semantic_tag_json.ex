defmodule RenewCollabWeb.SemanticTagJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{semantic_tags: semantic_tags}) do
    %{
      semantic_tags: semantic_tags
    }
  end
end
