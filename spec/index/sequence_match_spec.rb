# frozen_string_literal: true

require_relative "shared_examples"

RSpec.describe MemDB::Index::SequenceMatch do
  let(:index) { described_class.new(idx: MemDB::Idx::Bytes.new(:path)) }

  it_behaves_like "index", "exact match", {
    indexing: [
      [{path: "abc"}, :abc]
    ],
    query: {path: "abc"},
    expect: [:abc]
  }

  it_behaves_like "index", "no match", {
    indexing: [
      [{path: "0abc0"}, :zero_abc_zero]
    ],
    query: {path: "abc"},
    expect: []
  }

  it_behaves_like "index", "contains substring", {
    indexing: [
      [{path: "abc"}, :abc]
    ],
    query: {path: "0abc0"},
    expect: [:abc]
  }

  it_behaves_like "index", "sequence does not match", {
    indexing: [
      [{path: "abcd"}, :abcd]
    ],
    query: {path: "abcz"},
    expect: []
  }

  context "when text case mismatch" do
    it_behaves_like "index", "exact match", {
      indexing: [
        [{path: "aBC"}, :abc]
      ],
      query: {path: "ABc"},
      expect: []
    }

    it_behaves_like "index", "contains substring", {
      indexing: [
        [{path: "aBC"}, :abc]
      ],
      query: {path: "0ABc0"},
      expect: []
    }

    context "when downcase decorator applied" do
      let(:index) { described_class.new(idx: MemDB::Idx::Bytes.new(:path).downcase) }

      it_behaves_like "index", "exact match", {
        indexing: [
          [{path: "aBC"}, :abc]
        ],
        query: {path: "ABc"},
        expect: [:abc]
      }

      it_behaves_like "index", "contains substring", {
        indexing: [
          [{path: "aBC"}, :abc]
        ],
        query: {path: "0ABc0"},
        expect: [:abc]
      }
    end
  end

  describe described_class::Bucket do
    let(:index) do
      MemDB::Index::Enum.new(
        idx: MemDB::Idx::Itself.new(:category),
        bucket: described_class.new(
          idx: MemDB::Idx::Bytes.new(:word)
        )
      )
    end

    it_behaves_like "index", "match", {
      indexing: [
        [{word: "banana", category: "clothes"}, :clothes_banana],
        [{word: "banana", category: "food"}, :food_banana]
      ],
      query: {word: "delicious banana fresh", category: "food"},
      expect: [:food_banana]
    }
    it_behaves_like "index", "multiple match", {
      indexing: [
        [{word: "banana", category: "clothes"}, :clothes_banana],
        [{word: "banana", category: "food"}, :food_banana],
        [{word: "orange", category: "clothes"}, :clothes_orange],
        [{word: "orange", category: "food"}, :food_orange]
      ],
      query: {word: "big orange cap", category: %w[clothes food]},
      expect: %i[food_orange clothes_orange]
    }
    it_behaves_like "index", "multiple match 2", {
      indexing: [
        [{word: "banana", category: "clothes"}, :clothes_banana],
        [{word: "banana", category: "food"}, :food_banana],
        [{word: "orange", category: "clothes"}, :clothes_orange],
        [{word: "orange", category: "food"}, :food_orange]
      ],
      query: {word: ["big orange cap", "shaped as banana costume"], category: "clothes"},
      expect: [:clothes_banana, :clothes_orange]
    }
  end
end
