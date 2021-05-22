# frozen_string_literal: true

require "mem_db/idx"

class MemDB
  module Idx
    class Default
      include MemDB::Idx

      def initialize(original, default)
        @original = original
        @default = default
      end

      def field
        @original.field
      end

      def value(obj)
        v = obj[field]
        if v.nil?
          @default
        else
          @original.value(obj)
        end
      end

      def prepare_query(query)
        @original.prepare_query(query)
      end
    end
  end
end
