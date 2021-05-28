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

  context "when text case mismatch" do
    it_behaves_like "index", "exact match", {
      indexing: [
        [{pref: "aBC"}, :abc]
      ],
      query: {pref: "ABc"},
      expect: []
    }

    it_behaves_like "index", "query extends prefix", {
      indexing: [
        [{pref: "aBC"}, :abc]
      ],
      query: {pref: "ABcb"},
      expect: []
    }

    it_behaves_like "index", "multiple prefixes matches", {
      indexing: [
        [{pref: "aBC"}, :abc],
        [{pref: "aB"}, :ab]
      ],
      query: {pref: "ABc"},
      expect: []
    }

    it_behaves_like "index", "only one of prefixes matches", {
      indexing: [
        [{pref: "aBC"}, :abc],
        [{pref: "aB"}, :ab]
      ],
      query: {pref: "Ab"},
      expect: []
    }

    it_behaves_like "index", "one of prefixes matches", {
      indexing: [
        [{pref: ["aBC", "xYZ"]}, :abc_or_xyz]
      ],
      query: {pref: "ABc"},
      expect: []
    }

    it_behaves_like "index", "one of prefixes matches 2", {
      indexing: [
        [{pref: ["aBC", "xYZ"]}, :abc_or_xyz]
      ],
      query: {pref: "XYz"},
      expect: []
    }

    it_behaves_like "index", "many prefixes matches for single multi-value query", {
      indexing: [
        [{pref: ["aBC", "xYZ"]}, :abc_or_xyz]
      ],
      query: {pref: ["ABc", "XYz"]},
      expect: []
    }

    it_behaves_like "index", "many prefixes matches for single-value query", {
      indexing: [
        [{pref: ["aBC", "aB"]}, :abc_or_ab]
      ],
      query: {pref: "ABc"},
      expect: []
    }

    it_behaves_like "index", "multiple values matches to multi-value queries", {
      indexing: [
        [{pref: "aBC"}, :abc],
        [{pref: "xYZ"}, :xyz]
      ],
      query: {pref: ["ABc", "XYz"]},
      expect: []
    }

    context "when downcase decorator applied" do
      let(:index) { described_class.new(idx: MemDB::Idx::Chars.new(:pref).downcase) }

      it_behaves_like "index", "exact match", {
        indexing: [
          [{pref: "aBC"}, :abc]
        ],
        query: {pref: "ABc"},
        expect: [:abc]
      }

      it_behaves_like "index", "query extends prefix", {
        indexing: [
          [{pref: "aBC"}, :abc]
        ],
        query: {pref: "ABcb"},
        expect: [:abc]
      }

      it_behaves_like "index", "multiple prefixes matches", {
        indexing: [
          [{pref: "aBC"}, :abc],
          [{pref: "aB"}, :ab]
        ],
        query: {pref: "ABc"},
        expect: [:abc, :ab]
      }

      it_behaves_like "index", "only one of prefixes matches", {
        indexing: [
          [{pref: "aBC"}, :abc],
          [{pref: "aB"}, :ab]
        ],
        query: {pref: "Ab"},
        expect: [:ab]
      }

      it_behaves_like "index", "one of prefixes matches", {
        indexing: [
          [{pref: ["aBC", "xYZ"]}, :abc_or_xyz]
        ],
        query: {pref: "ABc"},
        expect: [:abc_or_xyz]
      }

      it_behaves_like "index", "one of prefixes matches 2", {
        indexing: [
          [{pref: ["aBC", "xYZ"]}, :abc_or_xyz]
        ],
        query: {pref: "XYz"},
        expect: [:abc_or_xyz]
      }

      it_behaves_like "index", "many prefixes matches for single multi-value query", {
        indexing: [
          [{pref: ["aBC", "xYZ"]}, :abc_or_xyz]
        ],
        query: {pref: ["ABc", "XYz"]},
        expect: [:abc_or_xyz, :abc_or_xyz]
      }

      it_behaves_like "index", "many prefixes matches for single-value query", {
        indexing: [
          [{pref: ["aBC", "aB"]}, :abc_or_ab]
        ],
        query: {pref: "ABc"},
        expect: [:abc_or_ab, :abc_or_ab]
      }

      it_behaves_like "index", "multiple values matches to multi-value queries", {
        indexing: [
          [{pref: "aBC"}, :abc],
          [{pref: "xYZ"}, :xyz]
        ],
        query: {pref: ["ABc", "XYz"]},
        expect: [:abc, :xyz]
      }
    end
  end

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
