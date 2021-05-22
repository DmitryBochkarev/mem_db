# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class MayMissing
      include MemDB::Field

      class Any
        include MemDB::Field::Matching

        def match?(_query)
          true
        end
      end

      ANY_MATCHING = Any.new

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
        v = obj[field]

        if v.nil?
          ANY_MATCHING
        else
          @original.new_matching(obj)
        end
      end
    end
  end
end
