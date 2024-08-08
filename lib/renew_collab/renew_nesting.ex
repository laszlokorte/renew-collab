defmodule RenewCollab.RenewNesting do
	import Ecto.Query, only: [from: 2, union: 2]

	def repair_parenthood do
		invalid = find_invalids()
		missing = find_missing()
		
		ids_to_delete = invalid |> Enum.map(fn	%{id: id} -> id end)
		rows_to_insert = missing |> Enum.map(&Map.take(&1, [:document_id, :ancestor_id, :descendant_id, :depth]))

		RenewCollab.Repo.transaction(fn _ -> 
			RenewCollab.Repo.delete_all(from p in RenewCollab.Renew.ElementParenthood, where: p.id in ^ids_to_delete)
			RenewCollab.Repo.insert_all(RenewCollab.Renew.ElementParenthood, rows_to_insert)
		end)
	end

	defp find_missing do
		transitives = from a in "element_parenthood", 
		  	as: :parent_a,
			join: b in "element_parenthood",
		  	on: true,
		  	as: :parent_b,
			where: a.id != b.id and a.document_id == b.document_id and b.ancestor_id == a.descendant_id and
			not exists(from t in "element_parenthood", 
				where: 
				{t.ancestor_id, t.descendant_id, t.depth} == {parent_as(:parent_a).ancestor_id, parent_as(:parent_b).descendant_id, parent_as(:parent_a).depth + parent_as(:parent_b).depth},
				select: %{id: t.id}
			),
			select: %{
				document_id: a.document_id,
				ancestor_id: a.ancestor_id,
				descendant_id: b.descendant_id,
				depth: a.depth + b.depth,
				reason: "transitivity"
			}

		reflexives = from m in "element",
			left_join: y in "element_parenthood",
        	on: {m.id, m.id, 0} == {y.ancestor_id, y.descendant_id, y.depth},
        	where: is_nil(y.id),
	        select: %{
		        document_id: m.document_id,
				ancestor_id: m.id,
				descendant_id: m.id,
				depth: 0,
				reason: "reflexivity"  
	      }

	     RenewCollab.Repo.all(union(transitives, ^reflexives))
	end

	defp find_invalids do
		transitives = from a in "element_parenthood",
			join: b in "element_parenthood",
		        on: a.descendant_id == b.ancestor_id,
		        where: {a.document_id, b.document_id} == {parent_as(:parent_query).document_id, parent_as(:parent_query).document_id}
				and a.depth + b.depth == parent_as(:parent_query).depth
				and a.id != parent_as(:parent_query).id
				and b.id != parent_as(:parent_query).id
				and {parent_as(:parent_query).ancestor_id, parent_as(:parent_query).descendant_id} == {a.ancestor_id, b.descendant_id},
		      select: %{
		        id: a.id
		      }

		 query = from p in "element_parenthood", 
		  as: :parent_query,
	      where:
	        (p.depth == 0 and p.descendant_id != p.ancestor_id) or
	        (p.depth != 0 and p.descendant_id == p.ancestor_id) or
	        (p.depth > 1 and not exists(transitives)),
	      select: %{
	        id: p.id
	      }

		RenewCollab.Repo.all(query)
	end
end