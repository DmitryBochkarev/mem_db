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

      def new_matching(value)
        NegativeMatching.new(@original.new_matching(value))
      end

      def field_value(obj)
        @original.field_value(obj)
      end

      def prepare_query(obj)
        @original.prepare_query(obj)
      end
    end
  end
end
