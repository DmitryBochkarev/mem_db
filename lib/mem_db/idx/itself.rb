# frozen_string_literal: true

require "mem_db/idx"

class MemDB
  module Idx
    class Itself
      include MemDB::Idx

      attr_reader :field

      def initialize(field)
        @field = field
      end

      def map_value(val)
        val
      end

      def map_query(val)
        val
      end
    end
  end
end
