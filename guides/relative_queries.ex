RenewCollab.Queries.LayerHierarchyChildren.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
layer_id: "6b1b1a1d-c090-4faa-b523-952c38eb0554",
}) |>
RenewCollab.Queries.LayerHierarchyChildren.multi() |>
RenewCollab.Repo.transaction()
|> case do
{:ok, r} -> r
end |> Map.get(:result)

RenewCollab.Queries.LayerHierarchyChildren.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
layer_id: "28dc13c2-97f0-45ea-9a60-2570c4dbef2a",
}) |>
RenewCollab.Queries.LayerHierarchyChildren.multi() |>
RenewCollab.Repo.transaction()
|> case do
{:ok, r} -> r
end |> Map.get(:result)


RenewCollab.Queries.LayerHierarchySiblings.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
layer_id: "db6aad81-1305-4add-842b-e8f4828e2ba3",
}) |>
RenewCollab.Queries.LayerHierarchySiblings.multi() |>
RenewCollab.Repo.transaction()
|> case do
{:ok, r} -> r
end |> Map.get(:result)

RenewCollab.Queries.LayerHierarchySiblings.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
layer_id: "d3a08dfca-27c4-4532-b41e-5cd351976525",
}) |>
RenewCollab.Queries.LayerHierarchySiblings.multi() |>
RenewCollab.Repo.transaction()
|> case do
{:ok, r} -> r
end |> Map.get(:result)

RenewCollab.Queries.LayerHierarchySiblings.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
layer_id: "999c7b69-d603-4dea-8f09-3fe2805189b4",
}) |>
RenewCollab.Queries.LayerHierarchySiblings.multi() |>
RenewCollab.Repo.transaction()
|> case do
{:ok, r} -> r
end |> Map.get(:result)

RenewCollab.Queries.LayerHierarchySiblings.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
layer_id: "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb",
}) |>
RenewCollab.Queries.LayerHierarchySiblings.multi() |>
RenewCollab.Repo.transaction()
|> case do
{:ok, r} -> r
end |> Map.get(:result)

RenewCollab.Queries.LayerHierarchySiblings.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
}) |>
RenewCollab.Queries.LayerHierarchySiblings.multi() |>
RenewCollab.Repo.transaction()
|> case do
{:ok, r} -> r
end |> Map.get(:result)


RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "6b1b1a1d-c090-4faa-b523-952c38eb0554",
relative: :parent
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
end |> Map.get(:result) 

RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb ",
relative: :parent
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
end |> Map.get(:result) 


RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "28dc13c2-97f0-45ea-9a60-2570c4dbef2a",
relative: {:child, :first}
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
x -> dbg(x)
end |> Map.get(:result) 


RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "28dc13c2-97f0-45ea-9a60-2570c4dbef2a",
relative: {:child, :last}
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
x -> dbg(x)
end |> Map.get(:result) 


RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
relative: {:child, :first}
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
x -> dbg(x)
end |> Map.get(:result) 


RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
relative: {:child, :last}
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
x -> dbg(x)
end |> Map.get(:result) 


RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
relative: {:sibling, :prev}
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
x -> dbg(x)
end |> Map.get(:result) 



RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
relative: {:sibling, :next}
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
x -> dbg(x)
end |> Map.get(:result) 

RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "8fe9a6ea-ca0d-47eb-8201-e9d2a4bedbc0",
relative: {:sibling, :last}
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
end |> Map.get(:result) 

RenewCollab.Queries.LayerHierarchyRelative.new(%{
document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1", 
layer_id: "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb",
relative: {:sibling, :prev}
}) |> 
RenewCollab.Queries.LayerHierarchyRelative.multi() |> 
RenewCollab.Repo.transaction() 
|> case do 
{:ok, r} -> r
end |> Map.get(:result) 