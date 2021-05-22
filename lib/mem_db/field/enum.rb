# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class Enum
      include MemDB::Field

      class MultiMatching
        include MemDB::Field::Matching

        def initialize(enum, arr)
          @enum = enum
          @arr = arr
        end

        def match?(query)
          @enum.query_value(query).any? do |el|
            @arr.include?(el)
          end
        end
      end

      class SingleMatching
        include MemDB::Field::Matching

        def initialize(enum, el)
          @enum = enum
          @el = el
        end

        def match?(query)
          @enum.query_value(query).include?(@el)
        end
      end

      attr_reader :field

      def initialize(field)
        @field = field
      end

      def new_matching(obj)
        val = obj[field]

        if val.is_a?(Array)
          MultiMatching.new(self, val)
        else
          SingleMatching.new(self, val)
        end
      end
    end
  end
end
