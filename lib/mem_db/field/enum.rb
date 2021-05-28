# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class Enum
      include MemDB::Field

      class MultiMatching
        include MemDB::Field::Matching

        def initialize(arr)
          @arr = arr
        end

        def match?(values)
          values.any? { |el| @arr.include?(el) }
        end
      end

      class SingleMatching
        include MemDB::Field::Matching

        def initialize(el)
          @el = el
        end

        def match?(values)
          values.include?(@el)
        end
      end

      attr_reader :field

      def initialize(field)
        @field = field
      end

      def new_matching(value)
        if value.is_a?(Array)
          MultiMatching.new(value)
        else
          SingleMatching.new(value)
        end
      end
    end
  end
end
