defmodule RenewCollab.QueryTest do
  use RenewCollab.DataCase

  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Queries.LayerHierarchyChildren
  alias RenewCollab.Queries.LayerHierarchyChildren
  alias RenewCollab.Queries.LayerHierarchyRelative
  alias RenewCollab.Queries.LayerHierarchySiblings

  describe "fixtures" do
    test "document count" do
      RenewCollab.DocumentFixtures.document_fixture()

      assert 4 == from(d in Document, select: count()) |> Repo.one()

      assert 1 ==
               from(d in Document,
                 select: count(),
                 where: d.id == ^"8ad232eb-ab87-4504-8fb0-453be196d7e1"
               )
               |> Repo.one()

      assert 1 ==
               from(d in Layer,
                 select: count(),
                 where: d.id == ^"1cde3234-22c6-4b13-93a9-76d524da8267"
               )
               |> Repo.one()
    end
  end

  describe "relative layers" do
    @queries [
      {LayerHierarchyChildren.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "6b1b1a1d-c090-4faa-b523-952c38eb0554",
         id_only: true
       }), []},
      {LayerHierarchyChildren.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "28dc13c2-97f0-45ea-9a60-2570c4dbef2a",
         id_only: true
       }),
       [
         "999c7b69-d603-4dea-8f09-3fe2805189b4",
         "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
         "6b1b1a1d-c090-4faa-b523-952c38eb0554",
         "f7dc9116-7e26-4aae-b721-c239d422c204",
         "1cde3234-22c6-4b13-93a9-76d524da8267"
       ]},
      {LayerHierarchyChildren.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
         id_only: true
       }), ["3a08dfca-27c4-4532-b41e-5cd351976525"]},
      {LayerHierarchySiblings.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "db6aad81-1305-4add-842b-e8f4828e2ba3",
         id_only: true
       }), ["55b34c1d-b029-45a5-a0d9-6885ffcbf2bb"]},
      {LayerHierarchySiblings.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "d3a08dfca-27c4-4532-b41e-5cd351976525",
         id_only: true
       }), []},
      {LayerHierarchySiblings.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "8fe9a6ea-ca0d-47eb-8201-e9d2a4bedbc0",
         id_only: true
       }), []},
      {LayerHierarchySiblings.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "999c7b69-d603-4dea-8f09-3fe2805189b4",
         id_only: true
       }),
       [
         "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
         "6b1b1a1d-c090-4faa-b523-952c38eb0554",
         "f7dc9116-7e26-4aae-b721-c239d422c204",
         "1cde3234-22c6-4b13-93a9-76d524da8267"
       ]},
      {LayerHierarchySiblings.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb",
         id_only: true
       }), ["db6aad81-1305-4add-842b-e8f4828e2ba3"]},
      {LayerHierarchySiblings.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
         id_only: true
       }),
       [
         "999c7b69-d603-4dea-8f09-3fe2805189b4",
         "6b1b1a1d-c090-4faa-b523-952c38eb0554",
         "f7dc9116-7e26-4aae-b721-c239d422c204",
         "1cde3234-22c6-4b13-93a9-76d524da8267"
       ]},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "6b1b1a1d-c090-4faa-b523-952c38eb0554",
         id_only: true,
         relative: :parent
       }), "28dc13c2-97f0-45ea-9a60-2570c4dbef2a"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb ",
         id_only: true,
         relative: :parent
       }), nil},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "28dc13c2-97f0-45ea-9a60-2570c4dbef2a",
         id_only: true,
         relative: {:child, :first}
       }), "999c7b69-d603-4dea-8f09-3fe2805189b4"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "28dc13c2-97f0-45ea-9a60-2570c4dbef2a",
         id_only: true,
         relative: {:child, :last}
       }), "1cde3234-22c6-4b13-93a9-76d524da8267"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
         id_only: true,
         relative: {:child, :first}
       }), "3a08dfca-27c4-4532-b41e-5cd351976525"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
         id_only: true,
         relative: {:child, :last}
       }), "3a08dfca-27c4-4532-b41e-5cd351976525"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
         id_only: true,
         relative: {:sibling, :prev}
       }), "999c7b69-d603-4dea-8f09-3fe2805189b4"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "5ca95a38-3fb6-44a9-add6-21937f8c49e1",
         id_only: true,
         relative: {:sibling, :next}
       }), "6b1b1a1d-c090-4faa-b523-952c38eb0554"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "8fe9a6ea-ca0d-47eb-8201-e9d2a4bedbc0",
         id_only: true,
         relative: {:sibling, :last}
       }), nil},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb",
         id_only: true,
         relative: {:sibling, :prev}
       }), "db6aad81-1305-4add-842b-e8f4828e2ba3"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb",
         id_only: true,
         relative: {:sibling, :next}
       }), nil},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "db6aad81-1305-4add-842b-e8f4828e2ba3",
         id_only: true,
         relative: {:sibling, :next}
       }), "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "55b34c1d-b029-45a5-a0d9-6885ffcbf2bb",
         id_only: true,
         relative: {:sibling, :first}
       }), "db6aad81-1305-4add-842b-e8f4828e2ba3"},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "db6aad81-1305-4add-842b-e8f4828e2ba3",
         id_only: true,
         relative: {:sibling, :first}
       }), nil},
      {LayerHierarchyRelative.new(%{
         document_id: "8ad232eb-ab87-4504-8fb0-453be196d7e1",
         layer_id: "1cde3234-22c6-4b13-93a9-76d524da8267",
         id_only: true,
         relative: {:sibling, :first}
       }), "999c7b69-d603-4dea-8f09-3fe2805189b4"}
    ]

    test "document count" do
      RenewCollab.DocumentFixtures.document_fixture()

      for {%{__struct__: t} = q, expected} <- @queries do
        assert {:ok, %{result: ^expected}} = t.multi(q) |> Repo.transaction()
      end
    end
  end
end
