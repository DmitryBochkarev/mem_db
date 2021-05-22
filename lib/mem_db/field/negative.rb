# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class Negative
      include MemDB::Field

      class NegativeMatching
        include MemDB::Field::Matching

        def initialize(original)
          @original = original
        end

        def match?(query)
          !@original.match?(query)
        end
      end

      def initialize(original)
        @original = original
      end

      def field
        @original.field
      end

      def query_field
        @original.query_field
      end

      def new_matching(obj)
        NegativeMatching.new(@original.new_matching(obj))
      end
    end
  end
end
