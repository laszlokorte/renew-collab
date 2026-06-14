defmodule RenewCollab.Repo.Migrations.AddSpecialEdgeSyntaxRules do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Syntax.SyntaxEdgeWhitelist
  alias RenewCollab.Syntax.SyntaxType

  @reference_net_syntax_id "fbf7adeb-9f28-49b3-a475-0bf37dd6d376"
  @place "de.renew.gui.PlaceFigure"
  @transition "de.renew.gui.TransitionFigure"
  @virtual_place "de.renew.gui.VirtualPlaceFigure"
  @virtual_transition "de.renew.gui.VirtualTransitionFigure"
  @double_arc "de.renew.gui.DoubleArcConnection"
  @inhibitor_arc "de.renew.gui.InhibitorConnection"
  @clear_arc "de.renew.gui.HollowDoubleArcConnection"

  def up do
    if reference_net_syntax_exists?() do
      net_pairs()
      |> Enum.each(fn {source, target} ->
        add_whitelist(source, target, @double_arc)
        add_whitelist(source, target, @inhibitor_arc)
      end)

      add_whitelist(@place, @transition, @clear_arc)
    end
  end

  def down do
    remove_edge(@double_arc)
    remove_edge(@inhibitor_arc)
    remove_edge(@clear_arc)
  end

  defp reference_net_syntax_exists? do
    repo().exists?(from(s in SyntaxType, where: s.id == ^@reference_net_syntax_id))
  end

  defp net_pairs do
    [
      {@transition, @place},
      {@transition, @virtual_place},
      {@virtual_transition, @place},
      {@virtual_transition, @virtual_place},
      {@place, @transition},
      {@place, @virtual_transition},
      {@virtual_place, @transition},
      {@virtual_place, @virtual_transition}
    ]
  end

  defp add_whitelist(source_semantic_tag, target_semantic_tag, edge_semantic_tag) do
    exists? =
      repo().exists?(
        from(w in SyntaxEdgeWhitelist,
          where:
            w.syntax_id == ^@reference_net_syntax_id and
              w.source_semantic_tag == ^source_semantic_tag and
              w.target_semantic_tag == ^target_semantic_tag and
              w.edge_semantic_tag == ^edge_semantic_tag
        )
      )

    unless exists? do
      repo().insert_all(SyntaxEdgeWhitelist, [
        %{
          id: Ecto.UUID.generate(),
          syntax_id: @reference_net_syntax_id,
          source_semantic_tag: source_semantic_tag,
          target_semantic_tag: target_semantic_tag,
          edge_semantic_tag: edge_semantic_tag
        }
      ])
    end
  end

  defp remove_edge(edge_semantic_tag) do
    repo().delete_all(
      from(w in SyntaxEdgeWhitelist,
        where:
          w.syntax_id == ^@reference_net_syntax_id and w.edge_semantic_tag == ^edge_semantic_tag
      )
    )
  end
end
