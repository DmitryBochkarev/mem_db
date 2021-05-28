# frozen_string_literal: true

RSpec.shared_examples "field" do |name, ex|
  context "#{name}: matching #{ex[:matching]} and quering #{ex[:query]}" do
    let(:obj) { MemDB::IndexingObject.new.assign!(ex[:matching]) }
    let(:matching) { field.new_matching(field.field_value(obj)) }
    let(:query) { MemDB::Query.new(ex[:query]) }
    subject(:result) { matching.match?(query.field_value(field)) }

    it { expect(result).to eq(ex[:expect]) }
  end
end
