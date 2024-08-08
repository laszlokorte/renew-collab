defmodule RenewCollab.RenewNesting do
	import Ecto.Query, only: [from: 2]

	def repair_parenthood do
		RenewCollab.Repo.transaction(fn ->
			with {:ok, invalid} <- to_remove(),
				{:ok, missing} <- to_add() do
				
				ids_to_delete = invalid.rows |> Enum.map(fn	[id] -> id end)
				rows_to_insert = missing.rows |> Enum.map(fn [doc, anc, dec, depth] -> %{
					depth: depth,
					document_id: doc,
					ancestor_id: anc,
					descendant_id: dec,
				} end)

				RenewCollab.Repo.delete_all(from p in RenewCollab.Renew.ElementParenthood, where: p.id in ^ids_to_delete)
				RenewCollab.Repo.insert_all(RenewCollab.Renew.ElementParenthood, rows_to_insert)
			end
		end)
	end

	defp to_add do
		Ecto.Adapters.SQL.query(RenewCollab.Repo, "SELECT
				a.document_id AS document_id,
				a.ancestor_id AS x,
				b.descendant_id AS y,
				a.depth + b.depth AS depth
			FROM
				element_parenthood a,
				element_parenthood b
			WHERE
				a.id <> b.id
				AND
				a.document_id = b.document_id
				AND
				b.ancestor_id = a.descendant_id
				AND
				NOT EXISTS (
					SELECT id
					FROM element_parenthood t WHERE
					(t.ancestor_id, t.descendant_id, t.depth)
					IS (a.ancestor_id, b.descendant_id, a.depth + b.depth)
				)
			UNION
			SELECT
				m.document_id AS document_id,
				id AS x,
				id AS y,
				0 AS depth
			FROM
				element m
			WHERE
				NOT EXISTS (
					SELECT id FROM element_parenthood r
					WHERE (r.ancestor_id, r.descendant_id, r.depth)
					IS (m.id, m.id, 0)
				)")
	end

	defp to_remove do
		Ecto.Adapters.SQL.query(RenewCollab.Repo, "SELECT
			id
			FROM
			element_parenthood p
			WHERE
			(
			p.depth = 0
			AND
			p.descendant_id <> p.ancestor_id
			) OR (
			p.depth <> 0
			AND
			p.descendant_id IS p.ancestor_id
			) OR (
			p.depth > 1
			AND
			NOT EXISTS (
				SELECT
					a.id
				FROM
					element_parenthood a
				INNER JOIN element_parenthood b
				ON a.descendant_id = b.ancestor_id
				WHERE
					(a.document_id, b.document_id) IS (p.document_id, p.document_id)
					AND (a.depth + b.depth) IS p.depth
					AND a.id <> p.id
					AND b.id <> p.id
					AND (p.ancestor_id, p.descendant_id)
					IS (a.ancestor_id, b.descendant_id)
			))")
	end
end