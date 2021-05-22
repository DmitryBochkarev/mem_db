# frozen_string_literal: true

require_relative "shared_examples"

RSpec.describe MemDB::Index::PrefixTree do
  let(:index) { described_class.new(idx: MemDB::Idx::Chars.new(:pref)) }

  it_behaves_like "index", "exact match", {
    indexing: [
      [{pref: "abc"}, :abc]
    ],
    query: {pref: "abc"},
    expect: [:abc]
  }
  it_behaves_like "index", "query extends prefix", {
    indexing: [
      [{pref: "abc"}, :abc]
    ],
    query: {pref: "abcb"},
    expect: [:abc]
  }
  it_behaves_like "index", "prefix is longer than query", {
    indexing: [
      [{pref: "abc"}, :abc]
    ],
    query: {pref: "ab"},
    expect: []
  }
  it_behaves_like "index", "multiple prefixes matches", {
    indexing: [
      [{pref: "abc"}, :abc],
      [{pref: "ab"}, :ab]
    ],
    query: {pref: "abc"},
    expect: [:abc, :ab]
  }
  it_behaves_like "index", "only one of prefixes matches", {
    indexing: [
      [{pref: "abc"}, :abc],
      [{pref: "ab"}, :ab]
    ],
    query: {pref: "ab"},
    expect: [:ab]
  }
  it_behaves_like "index", "one of prefixes matches", {
    indexing: [
      [{pref: ["abc", "xyz"]}, :abc_or_xyz]
    ],
    query: {pref: "abc"},
    expect: [:abc_or_xyz]
  }
  it_behaves_like "index", "one of prefixes matches 2", {
    indexing: [
      [{pref: ["abc", "xyz"]}, :abc_or_xyz]
    ],
    query: {pref: "xyz"},
    expect: [:abc_or_xyz]
  }
  it_behaves_like "index", "many prefixes matches for single multi-value query", {
    indexing: [
      [{pref: ["abc", "xyz"]}, :abc_or_xyz]
    ],
    query: {pref: ["abc", "xyz"]},
    expect: [:abc_or_xyz, :abc_or_xyz]
  }
  it_behaves_like "index", "many prefixes matches for single-value query", {
    indexing: [
      [{pref: ["abc", "ab"]}, :abc_or_ab]
    ],
    query: {pref: "abc"},
    expect: [:abc_or_ab, :abc_or_ab]
  }
  it_behaves_like "index", "multiple values matches to multi-value queries", {
    indexing: [
      [{pref: "abc"}, :abc],
      [{pref: "xyz"}, :xyz]
    ],
    query: {pref: ["abc", "xyz"]},
    expect: [:abc, :xyz]
  }

  describe described_class::Bucket do
    let(:index) do
      MemDB::Index::Enum.new(
        idx: MemDB::Idx::Itself.new(:category),
        bucket: MemDB::Index::PrefixTree::Bucket.new(
          idx: MemDB::Idx::Chars.new(:breadcrumbs)
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

  context "when used as suffix tree" do
    let(:index) do
      described_class.new(
        idx: MemDB::Idx::Reverse.new(
          MemDB::Idx::Chars.new(:suffix)
        )
      )
    end

    it_behaves_like "index", "exact match", {
      indexing: [
        [{suffix: "abc"}, :abc]
      ],
      query: {suffix: "abc"},
      expect: [:abc]
    }
    it_behaves_like "index", "match by suffix", {
      indexing: [
        [{suffix: "abc"}, :abc]
      ],
      query: {suffix: "0abc"},
      expect: [:abc]
    }
    it_behaves_like "index", "no match by suffix", {
      indexing: [
        [{suffix: "abc0"}, :abc]
      ],
      query: {suffix: "abc"},
      expect: []
    }
  end
end
