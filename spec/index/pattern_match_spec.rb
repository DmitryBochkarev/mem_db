# frozen_string_literal: true

require_relative "shared_examples"

RSpec.describe MemDB::Index::PatternMatch do
  let(:index) { described_class.new(idx: MemDB::Idx::Pattern.new(:path)) }

  it_behaves_like "index", "exact match", {
    indexing: [
      [{path: "abc"}, :abc]
    ],
    query: {path: "abc"},
    expect: [:abc]
  }

  it_behaves_like "index", "match by prefix", {
    indexing: [
      [{path: "abc*"}, :abc]
    ],
    query: {path: "abcd"},
    expect: [:abc]
  }

  it_behaves_like "index", "match by suffix", {
    indexing: [
      [{path: "*abc"}, :abc]
    ],
    query: {path: "0abc"},
    expect: [:abc]
  }

  it_behaves_like "index", "match by substring", {
    indexing: [
      [{path: "*abc*"}, :abc]
    ],
    query: {path: "0abc0"},
    expect: [:abc]
  }

  it_behaves_like "index", "match by substring in multiline", {
    indexing: [
      [{path: "*abc*"}, :abc]
    ],
    query: {path: "\r\n0abc0\r\n"},
    expect: [:abc]
  }

  it_behaves_like "index", "when prefix longer than suffix matches by prefix", {
    indexing: [
      [{path: "abcd*efg"}, :abc]
    ],
    query: {path: "abcdx"},
    expect: [:abc]
  }

  it_behaves_like "index", "when suffix longer than prefix matches by suffix", {
    indexing: [
      [{path: "abc*defg"}, :abc]
    ],
    query: {path: "xdefg"},
    expect: [:abc]
  }

  it_behaves_like "index", "when prefix and suffix are short should match by substring", {
    indexing: [
      [{path: "a*bcd*e"}, :bcd]
    ],
    query: {path: "0bcd0"},
    expect: [:bcd]
  }

  it_behaves_like "index", "match all relevant patterns", {
    indexing: [
      [{path: "abc"}, :exact],
      [{path: "abc*"}, :prefix],
      [{path: "*abc"}, :suffix],
      [{path: "*abc*"}, :substring]
    ],
    query: {path: "abc"},
    expect: [:exact, :prefix, :suffix, :substring]
  }

  context "when text case mismatch" do
    it_behaves_like "index", "exact match", {
      indexing: [
        [{path: "aBC"}, :abc]
      ],
      query: {path: "ABc"},
      expect: []
    }

    it_behaves_like "index", "match by prefix", {
      indexing: [
        [{path: "aBC*"}, :abc]
      ],
      query: {path: "ABcd"},
      expect: []
    }

    it_behaves_like "index", "match by suffix", {
      indexing: [
        [{path: "*aBC"}, :abc]
      ],
      query: {path: "0ABc"},
      expect: []
    }

    it_behaves_like "index", "match by substring", {
      indexing: [
        [{path: "*aBC*"}, :abc]
      ],
      query: {path: "0ABc0"},
      expect: []
    }

    it_behaves_like "index", "match by substring in multiline", {
      indexing: [
        [{path: "*aBC*"}, :abc]
      ],
      query: {path: "\r\n0ABc0\r\n"},
      expect: []
    }

    it_behaves_like "index", "when prefix longer than suffix matches by prefix", {
      indexing: [
        [{path: "abCD*EFg"}, :abc]
      ],
      query: {path: "ABcdx"},
      expect: []
    }

    it_behaves_like "index", "when suffix longer than prefix matches by suffix", {
      indexing: [
        [{path: "aBC*DEfg"}, :abc]
      ],
      query: {path: "xdeFG"},
      expect: []
    }

    it_behaves_like "index", "when prefix and suffix are short should match by substring", {
      indexing: [
        [{path: "a*BCd*e"}, :bcd]
      ],
      query: {path: "0bCD0"},
      expect: []
    }

    it_behaves_like "index", "match all relevant patterns", {
      indexing: [
        [{path: "aBC"}, :exact],
        [{path: "aBC*"}, :prefix],
        [{path: "*aBC"}, :suffix],
        [{path: "*aBC*"}, :substring]
      ],
      query: {path: "ABc"},
      expect: []
    }

    context "when downcase decorator applied" do
      let(:index) { described_class.new(idx: MemDB::Idx::Pattern.new(:path).downcase) }

      it_behaves_like "index", "exact match", {
        indexing: [
          [{path: "aBC"}, :abc]
        ],
        query: {path: "ABc"},
        expect: [:abc]
      }

      it_behaves_like "index", "match by prefix", {
        indexing: [
          [{path: "aBC*"}, :abc]
        ],
        query: {path: "ABcd"},
        expect: [:abc]
      }

      it_behaves_like "index", "match by suffix", {
        indexing: [
          [{path: "*aBC"}, :abc]
        ],
        query: {path: "0ABc"},
        expect: [:abc]
      }

      it_behaves_like "index", "match by substring", {
        indexing: [
          [{path: "*aBC*"}, :abc]
        ],
        query: {path: "0ABc0"},
        expect: [:abc]
      }

      it_behaves_like "index", "match by substring in multiline", {
        indexing: [
          [{path: "*aBC*"}, :abc]
        ],
        query: {path: "\r\n0ABc0\r\n"},
        expect: [:abc]
      }

      it_behaves_like "index", "when prefix longer than suffix matches by prefix", {
        indexing: [
          [{path: "abCD*EFg"}, :abc]
        ],
        query: {path: "ABcdx"},
        expect: [:abc]
      }

      it_behaves_like "index", "when suffix longer than prefix matches by suffix", {
        indexing: [
          [{path: "aBC*DEfg"}, :abc]
        ],
        query: {path: "xdeFG"},
        expect: [:abc]
      }

      it_behaves_like "index", "when prefix and suffix are short should match by substring", {
        indexing: [
          [{path: "a*BCd*e"}, :bcd]
        ],
        query: {path: "0bCD0"},
        expect: [:bcd]
      }

      it_behaves_like "index", "match all relevant patterns", {
        indexing: [
          [{path: "aBC"}, :exact],
          [{path: "aBC*"}, :prefix],
          [{path: "*aBC"}, :suffix],
          [{path: "*aBC*"}, :substring]
        ],
        query: {path: "ABc"},
        expect: [:exact, :prefix, :suffix, :substring]
      }
    end
  end
end
