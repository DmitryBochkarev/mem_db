# frozen_string_literal: true

require_relative "shared_examples"

RSpec.describe MemDB::Index::Enum do
  let(:index) { described_class.new(idx: MemDB::Idx::Itself.new(:category)) }

  it_behaves_like "index", "exact match", {
    indexing: [
      [{category: ["clothes"]}, :clothes]
    ],
    query: {category: "clothes"},
    expect: [:clothes]
  }
  it_behaves_like "index", "match one of values", {
    indexing: [
      [{category: ["clothes", "food"]}, :clothes_and_food]
    ],
    query: {category: "clothes"},
    expect: [:clothes_and_food]
  }
  it_behaves_like "index", "match one of values 2", {
    indexing: [
      [{category: ["clothes", "food"]}, :clothes_and_food]
    ],
    query: {category: "food"},
    expect: [:clothes_and_food]
  }
  it_behaves_like "index", "match many values", {
    indexing: [
      [{category: ["clothes", "food"]}, :clothes_and_food]
    ],
    query: {category: ["clothes", "food"]},
    expect: [:clothes_and_food, :clothes_and_food]
  }
  it_behaves_like "index", "no match", {
    indexing: [
      [{category: ["clothes", "food"]}, :clothes_and_food]
    ],
    query: {category: "travel"},
    expect: []
  }
  it_behaves_like "index", "match one of value in query", {
    indexing: [
      [{category: ["clothes", "food"]}, :clothes_and_food]
    ],
    query: {category: ["food", "travel"]},
    expect: [:clothes_and_food]
  }
  it_behaves_like "index", "match one of value", {
    indexing: [
      [{category: "clothes"}, :clothes],
      [{category: "food"}, :food]
    ],
    query: {category: "food"},
    expect: [:food]
  }
  it_behaves_like "index", "match many indexed values", {
    indexing: [
      [{category: "clothes"}, :clothes],
      [{category: "food"}, :food]
    ],
    query: {category: ["clothes", "food"]},
    expect: [:clothes, :food]
  }

  describe described_class::Bucket do
    let(:index) do
      MemDB::Index::PrefixTree.new(
        idx: MemDB::Idx::Chars.new(:breadcrumbs),
        bucket: MemDB::Index::Enum::Bucket.new(
          idx: MemDB::Idx::Itself.new(:category)
        )
      )
    end

    it_behaves_like "index", "match", {
      indexing: [
        [{breadcrumbs: "/retail/", category: "clothes"}, :retail_clothes],
        [{breadcrumbs: "/retail/", category: "food"}, :retail_food]
      ],
      query: {breadcrumbs: "/retail/1", category: "food"},
      expect: [:retail_food]
    }
    it_behaves_like "index", "multiple match", {
      indexing: [
        [{breadcrumbs: "/retail/", category: "clothes"}, :retail_clothes],
        [{breadcrumbs: "/retail/", category: "food"}, :retail_food],
        [{breadcrumbs: "/wholesale/", category: "clothes"}, :wholesale_clothes],
        [{breadcrumbs: "/wholesale/", category: "food"}, :wholesale_food]
      ],
      query: {breadcrumbs: "/retail/1", category: ["clothes", "food"]},
      expect: [:retail_food, :retail_clothes]
    }
    it_behaves_like "index", "multiple match 2", {
      indexing: [
        [{breadcrumbs: "/retail/", category: "clothes"}, :retail_clothes],
        [{breadcrumbs: "/retail/", category: "food"}, :retail_food],
        [{breadcrumbs: "/wholesale/", category: "clothes"}, :wholesale_clothes],
        [{breadcrumbs: "/wholesale/", category: "food"}, :wholesale_food]
      ],
      query: {breadcrumbs: ["/retail/1", "/wholesale/2"], category: "clothes"},
      expect: [:retail_clothes, :wholesale_clothes]
    }
  end
end
