# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class Downcase
      include MemDB::Field

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
        @original.new_matching(value)
      end

      def field_value(obj)
        @original.field_value(obj).map(&:downcase)
      end

      def prepare_query(obj)
        @original.prepare_query(obj).map(&:downcase)
      end
    end
  end
end
