# frozen_string_literal: true

RSpec.shared_examples "index" do |name, ex|
  context "#{name}: indexing #{ex[:indexing]} and quering #{ex[:query]}" do
    before do
      indexation = MemDB::Indexation.new(index)

      ex[:indexing].each do |obj, value|
        indexation.add(obj, value)
      end
    end

    let(:query) { MemDB::Query.new(ex[:query]) }
    subject(:result) { query.using(index).to_a }

    it { expect(result).to match_array(ex[:expect]) }
  end
end
