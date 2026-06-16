defmodule RenewCollab.Repo.Migrations.AddVirtualNetSyntaxRules do
  use Ecto.Migration

  import Ecto.Query

  alias RenewCollab.Syntax.SyntaxEdgeAutoTarget
  alias RenewCollab.Syntax.SyntaxEdgeWhitelist
  alias RenewCollab.Syntax.SyntaxType

  @reference_net_syntax_id "fbf7adeb-9f28-49b3-a475-0bf37dd6d376"
  @place "de.renew.gui.PlaceFigure"
  @transition "de.renew.gui.TransitionFigure"
  @virtual_place "de.renew.gui.VirtualPlaceFigure"
  @virtual_transition "de.renew.gui.VirtualTransitionFigure"
  @arc "de.renew.gui.ArcConnection"
  @place_socket "9BE09A98-DECF-4D38-8A06-5381B51D7538"
  @transition_socket "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD"
  @place_shape "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42"
  @transition_shape "2DD432FE-CC8A-4259-8A84-63F75AF0ECE0"
  @arrow_tip "84DC6617-D555-4BAB-BA33-04A5FA442F00"

  def up do
    if reference_net_syntax_exists?() do
      add_whitelist(@transition, @virtual_place)
      add_whitelist(@virtual_transition, @place)
      add_whitelist(@virtual_transition, @virtual_place)
      add_whitelist(@place, @virtual_transition)
      add_whitelist(@virtual_place, @transition)
      add_whitelist(@virtual_place, @virtual_transition)

      add_auto_target(
        @virtual_transition,
        @transition_socket,
        @place_shape,
        @place_socket,
        @place
      )

      add_auto_target(
        @virtual_place,
        @place_socket,
        @transition_shape,
        @transition_socket,
        @transition
      )
    end
  end

  def down do
    remove_auto_target(@virtual_transition)
    remove_auto_target(@virtual_place)

    remove_whitelist(@transition, @virtual_place)
    remove_whitelist(@virtual_transition, @place)
    remove_whitelist(@virtual_transition, @virtual_place)
    remove_whitelist(@place, @virtual_transition)
    remove_whitelist(@virtual_place, @transition)
    remove_whitelist(@virtual_place, @virtual_transition)
  end

  defp reference_net_syntax_exists? do
    repo().exists?(from(s in SyntaxType, where: s.id == ^@reference_net_syntax_id))
  end

  defp add_whitelist(source_semantic_tag, target_semantic_tag) do
    exists? =
      repo().exists?(
        from(w in SyntaxEdgeWhitelist,
          where:
            w.syntax_id == ^@reference_net_syntax_id and
              w.source_semantic_tag == ^source_semantic_tag and
              w.target_semantic_tag == ^target_semantic_tag and
              w.edge_semantic_tag == ^@arc
        )
      )

    unless exists? do
      repo().insert_all(SyntaxEdgeWhitelist, [
        %{
          id: Ecto.UUID.generate(),
          syntax_id: @reference_net_syntax_id,
          source_semantic_tag: source_semantic_tag,
          target_semantic_tag: target_semantic_tag,
          edge_semantic_tag: @arc
        }
      ])
    end
  end

  defp remove_whitelist(source_semantic_tag, target_semantic_tag) do
    repo().delete_all(
      from(w in SyntaxEdgeWhitelist,
        where:
          w.syntax_id == ^@reference_net_syntax_id and
            w.source_semantic_tag == ^source_semantic_tag and
            w.target_semantic_tag == ^target_semantic_tag and
            w.edge_semantic_tag == ^@arc
      )
    )
  end

  defp add_auto_target(
         source_semantic_tag,
         source_socket_id,
         target_shape_id,
         target_socket_id,
         target_semantic_tag
       ) do
    exists? =
      repo().exists?(
        from(t in SyntaxEdgeAutoTarget,
          where:
            t.syntax_id == ^@reference_net_syntax_id and
              t.source_semantic_tag == ^source_semantic_tag and
              t.target_semantic_tag == ^target_semantic_tag and
              t.edge_semantic_tag == ^@arc
        )
      )

    unless exists? do
      repo().insert_all(SyntaxEdgeAutoTarget, [
        %{
          id: Ecto.UUID.generate(),
          syntax_id: @reference_net_syntax_id,
          source_semantic_tag: source_semantic_tag,
          source_socket_id: source_socket_id,
          target_shape_id: target_shape_id,
          target_semantic_tag: target_semantic_tag,
          target_socket_id: target_socket_id,
          edge_semantic_tag: @arc,
          edge_source_tip_id: nil,
          edge_target_tip_id: @arrow_tip,
          style: nil
        }
      ])
    end
  end

  defp remove_auto_target(source_semantic_tag) do
    repo().delete_all(
      from(t in SyntaxEdgeAutoTarget,
        where:
          t.syntax_id == ^@reference_net_syntax_id and
            t.source_semantic_tag == ^source_semantic_tag and
            t.edge_semantic_tag == ^@arc
      )
    )
  end
end
