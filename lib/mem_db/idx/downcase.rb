# frozen_string_literal: true

class MemDB
  module Idx
    class Downcase
      include MemDB::Idx

      def initialize(original)
        @original = original
      end

      def field
        @original.field
      end

      def map_value(str)
        @original.map_value(str.downcase)
      end

      def map_query(str)
        @original.map_query(str.downcase)
      end
    end
  end
end
