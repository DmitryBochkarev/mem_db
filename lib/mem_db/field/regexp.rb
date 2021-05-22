# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class Regexp
      include MemDB::Field

      class Rx
        def initialize(source)
          @rx = ::Regexp.new(source, ::Regexp::MULTILINE)
        end

        def match?(str)
          @rx.match?(str)
        end
      end

      class MultiMatching
        include MemDB::Field::Matching

        def initialize(field, arr)
          @field = field
          @patterns = arr.map { |source| Rx.new(source) }
        end

        def match?(query)
          @field.query_value(query).each do |str|
            return true if @patterns.any? { |pat| pat.match?(str) }
          end

          false
        end
      end

      class SingleMatching
        include MemDB::Field::Matching

        def initialize(field, el)
          @field = field
          @pat = Rx.new(el)
        end

        def match?(query)
          @field.query_value(query).any? { |str| @pat.match?(str) }
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
