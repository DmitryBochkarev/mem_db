# frozen_string_literal: true

require_relative "shared_examples"

RSpec.describe MemDB::Field::MayMissing do
  let(:field) { described_class.new(MemDB::Field::Enum.new(:category)) }

  it_behaves_like "field", "field is missing", {
    matching: {},
    query: {category: "food"},
    expect: true
  }

  it_behaves_like "field", "field is nil", {
    matching: {category: nil},
    query: {category: "food"},
    expect: true
  }

  it_behaves_like "field", "exact single match", {
    matching: {category: "food"},
    query: {category: "food"},
    expect: true
  }

  it_behaves_like "field", "exact single match to multiquery", {
    matching: {category: "food"},
    query: {category: ["games", "food"]},
    expect: true
  }

  it_behaves_like "field", "no exact single match", {
    matching: {category: "food"},
    query: {category: "games"},
    expect: false
  }

  it_behaves_like "field", "multiple match", {
    matching: {category: ["food", "clothes"]},
    query: {category: "food"},
    expect: true
  }

  it_behaves_like "field", "multiple match to multiquery", {
    matching: {category: ["food", "clothes"]},
    query: {category: ["games", "food"]},
    expect: true
  }

  it_behaves_like "field", "no multiple match", {
    matching: {category: ["food", "clothes"]},
    query: {category: "games"},
    expect: false
  }
end
