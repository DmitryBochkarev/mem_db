# frozen_string_literal: true

require_relative "shared_examples"

RSpec.describe MemDB::Field::Pattern do
  let(:field) { described_class.new(:text) }

  it_behaves_like "field", "exact single match", {
    matching: {text: "food"},
    query: {text: "food"},
    expect: true
  }

  it_behaves_like "field", "exact single match to multiquery", {
    matching: {text: "food"},
    query: {text: ["games", "food"]},
    expect: true
  }

  it_behaves_like "field", "no exact single match", {
    matching: {text: "food"},
    query: {text: "games"},
    expect: false
  }

  it_behaves_like "field", "multiple match", {
    matching: {text: ["food", "clothes"]},
    query: {text: "food"},
    expect: true
  }

  it_behaves_like "field", "multiple match to multiquery", {
    matching: {text: ["food", "clothes"]},
    query: {text: ["games", "food"]},
    expect: true
  }

  it_behaves_like "field", "no multiple match", {
    matching: {text: ["food", "clothes"]},
    query: {text: "games"},
    expect: false
  }

  it_behaves_like "field", "match by prefix", {
    matching: {text: "abc*"},
    query: {text: "abc"},
    expect: true
  }

  it_behaves_like "field", "match by prefix", {
    matching: {text: "abc*"},
    query: {text: "abc9"},
    expect: true
  }

  it_behaves_like "field", "match by suffix", {
    matching: {text: "*abc"},
    query: {text: "0abc"},
    expect: true
  }

  it_behaves_like "field", "match by suffix", {
    matching: {text: "*abc"},
    query: {text: "abc"},
    expect: true
  }

  it_behaves_like "field", "match by sequence", {
    matching: {text: "*abc*"},
    query: {text: "abc"},
    expect: true
  }

  it_behaves_like "field", "match by sequence", {
    matching: {text: "*abc*"},
    query: {text: "0abc"},
    expect: true
  }

  it_behaves_like "field", "match by sequence", {
    matching: {text: "*abc*"},
    query: {text: "abc9"},
    expect: true
  }

  it_behaves_like "field", "match by sequence", {
    matching: {text: "*abc*"},
    query: {text: "0abc9"},
    expect: true
  }

  it_behaves_like "field", "pattern is longer than text", {
    matching: {text: "abcd*"},
    query: {text: "abc"},
    expect: false
  }

  it_behaves_like "field", "pattern mismatched by suffix", {
    matching: {text: "*0abc"},
    query: {text: "abc"},
    expect: false
  }

  it_behaves_like "field", "pattern match", {
    matching: {text: "0*abc"},
    query: {text: "0abc"},
    expect: true
  }

  it_behaves_like "field", "pattern match 2", {
    matching: {text: "0*abc"},
    query: {text: "01234abc"},
    expect: true
  }

  it_behaves_like "field", "pattern match 3", {
    matching: {text: "*0*abc"},
    query: {text: "0abc"},
    expect: true
  }

  it_behaves_like "field", "pattern match 4", {
    matching: {text: "*0*abc"},
    query: {text: "-101abc"},
    expect: true
  }

  it_behaves_like "field", "pattern no match", {
    matching: {text: "*0*abc"},
    query: {text: "-101abc9"},
    expect: false
  }

  it_behaves_like "field", "pattern match 6", {
    matching: {text: "*0*abc*"},
    query: {text: "-101abc9"},
    expect: true
  }
end
