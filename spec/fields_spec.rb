# frozen_string_literal: true

RSpec.describe MemDB::Fields do
  let(:fields) { described_class.new(list) }
  let(:list) do
    [
      MemDB::Field::Enum.new(:category),
      MemDB::Field::Enum.new(:"!category").query(:category).negative,

      MemDB::Field::Regexp.new(:text),
      MemDB::Field::Regexp.new(:"!text").query(:text).negative,

      MemDB::Field::Pattern.new(:breadcrumbs),
      MemDB::Field::Pattern.new(:"!breadcrumbs").query(:breadcrumbs).negative
    ].map!(&:may_missing)
  end

  shared_examples "fields" do |name, ex|
    context "#{name}: matching #{ex[:matching]} and quering #{ex[:query]}" do
      let(:obj) { MemDB::IndexingObject.new.assign!(ex[:matching]) }
      let(:matching) { fields.new_matching(obj) }
      let(:query) { MemDB::Query.new(ex[:query]) }
      subject(:result) { matching.match?(query) }

      it { expect(result).to eq(ex[:expect]) }
    end
  end

  it_behaves_like "fields", "match", {
    matching: {
      category: "food",
      text: ".*fish.*",
      breadcrumbs: "*/retail/*"
    },
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: true
  }

  it_behaves_like "fields", "match by negative 1", {
    matching: {
      "!category": "food",
      text: ".*fish.*",
      breadcrumbs: "*/retail/*"
    },
    query: {
      category: "toy",
      text: "animated fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: true
  }

  it_behaves_like "fields", "match by negative 2", {
    matching: {
      category: "food",
      "!text": ".*fish.*",
      breadcrumbs: "*/retail/*"
    },
    query: {
      category: "food",
      text: "delicious banana",
      breadcrumbs: "/shops/retail/123"
    },
    expect: true
  }

  it_behaves_like "fields", "match by negative 3", {
    matching: {
      category: "food",
      text: ".*fish.*",
      "!breadcrumbs": "*/retail/*"
    },
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/wholesale/123"
    },
    expect: true
  }

  it_behaves_like "fields", "no match 1", {
    matching: {
      "!category": "food",
      text: ".*fish.*",
      breadcrumbs: "*/retail/*"
    },
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: false
  }

  it_behaves_like "fields", "no match 2", {
    matching: {
      category: "food",
      "!text": ".*fish.*",
      breadcrumbs: "*/retail/*"
    },
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: false
  }

  it_behaves_like "fields", "no match 3", {
    matching: {
      category: "food",
      text: ".*fish.*",
      "!breadcrumbs": "*/retail/*"
    },
    query: {
      category: "food",
      text: "delicious fish",
      breadcrumbs: "/shops/retail/123"
    },
    expect: false
  }
end
