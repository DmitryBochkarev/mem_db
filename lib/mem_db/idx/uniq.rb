# frozen_string_literal: true

class MemDB
  module Idx
    class Uniq
      include MemDB::Idx

      def initialize(original)
        @original = original
      end

      def field
        @original.field
      end

      def value(obj)
        val = @original.value(obj)
        return val if val == MemDB::Idx::ANY

        val.uniq
      end

      def prepare_query(query)
        @original.prepare_query(query).uniq
      end

      def map_value(raw)
        @original.map_value(raw)
      end

      def map_query(raw)
        @original.map_query(raw)
      end
    end
  end
end
