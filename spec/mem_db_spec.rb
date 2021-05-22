# frozen_string_literal: true

RSpec.describe MemDB do
  it "has a version number" do
    expect(MemDB::VERSION).not_to be nil
  end

  shared_examples "database" do |name, ex|
    context "#{name}: indexing #{ex[:indexing]} and quering #{ex[:query]}" do
      let(:query) { MemDB::Query.new(ex[:query]) }
      subject(:result) { query.using(database).to_a }

      before do
        indexation = database.new_indexation
        ex[:indexing].each do |obj, value|
          indexation.add(obj, value)
        end
      end

      it { expect(result).to match_array(ex[:expect]) }
    end
  end

  let(:fields) do
    MemDB::Fields.new([
      MemDB::Field::Enum.new(:category),
      MemDB::Field::Enum.new(:"!category").query(:category).negative,

      MemDB::Field::Regexp.new(:text),
      MemDB::Field::Regexp.new(:"!text").query(:text).negative,

      MemDB::Field::Pattern.new(:breadcrumbs),
      MemDB::Field::Pattern.new(:"!breadcrumbs").query(:breadcrumbs).negative
    ].map!(&:may_missing))
  end

  let(:index) do
    MemDB::Index.compose([
      MemDB::Index::Enum::Bucket.new(
        idx: MemDB::Idx::Itself.new(:category).default_any
      ).accept_any,
      MemDB::Index::PatternMatch::Bucket.new(
        idx: MemDB::Idx::Pattern.new(:breadcrumbs).default_any
      ).accept_any
    ])
  end

  let(:database) { described_class.new(fields, index) }

  it_behaves_like "database", "match", {
    indexing: [
      [
        {
          category: "food",
          text: ".*fish.*",
          breadcrumbs: "*/retail/*"
        },
        :food_fish
      ]
    ],
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: [:food_fish]
  }

  it_behaves_like "database", "match by negative 1", {
    indexing: [
      [
        {
          "!category": "food",
          text: ".*fish.*",
          breadcrumbs: "*/retail/*"
        },
        :not_food_fish
      ]
    ],
    query: {
      category: "toy",
      text: "animated fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: [:not_food_fish]
  }

  it_behaves_like "database", "match by negative 2", {
    indexing: [
      [
        {
          category: "food",
          "!text": ".*fish.*",
          breadcrumbs: "*/retail/*"
        },
        :food_not_fish
      ]
    ],
    query: {
      category: "food",
      text: "delicious banana",
      breadcrumbs: "/shops/retail/123"
    },
    expect: [:food_not_fish]
  }

  it_behaves_like "database", "match by negative 3", {
    indexing: [
      [
        {
          category: "food",
          text: ".*fish.*",
          "!breadcrumbs": "*/retail/*"
        },
        :food_fish_not_retail
      ]
    ],
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/wholesale/123"
    },
    expect: [:food_fish_not_retail]
  }

  it_behaves_like "database", "no match 1", {
    indexing: [
      [
        {
          "!category": "food",
          text: ".*fish.*",
          breadcrumbs: "*/retail/*"
        },
        :not_food_fish
      ]
    ],
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: []
  }

  it_behaves_like "database", "no match 2", {
    indexing: [
      [
        {
          category: "food",
          "!text": ".*fish.*",
          breadcrumbs: "*/retail/*"
        },
        :food_not_fish
      ]
    ],
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: []
  }

  it_behaves_like "database", "no match 3", {
    indexing: [
      [
        {
          category: "food",
          text: ".*fish.*",
          "!breadcrumbs": "*/retail/*"
        },
        :food_fish_not_retail
      ]
    ],
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: []
  }
end
