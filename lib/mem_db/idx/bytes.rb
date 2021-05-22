# frozen_string_literal: true

require "mem_db/idx"

class MemDB
  module Idx
    class Bytes
      include MemDB::Idx

      attr_reader :field

      def initialize(field)
        @field = field
      end

      def map_value(raw)
        raw.bytes
      end

      def map_query(text)
        text.bytes
      end
    end
  end
end
