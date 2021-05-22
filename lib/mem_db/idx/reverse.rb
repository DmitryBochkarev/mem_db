# frozen_string_literal: true

require "mem_db/idx"

class MemDB
  module Idx
    class Reverse
      include MemDB::Idx

      def initialize(original)
        @original = original
      end

      def field
        @original.field
      end

      def map_value(val)
        @original.map_value(val).reverse
      end

      def map_query(val)
        @original.map_query(val).reverse
      end
    end
  end
end
