# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class Regexp
      include MemDB::Field

      class Rx
        def initialize(source, ignore_case:)
          opts = ::Regexp::MULTILINE
          opts |= ::Regexp::IGNORECASE if ignore_case

          @rx = ::Regexp.new(source, opts)
        end

        def match?(str)
          @rx.match?(str)
        end
      end

      class MultiMatching
        include MemDB::Field::Matching

        def initialize(arr, ignore_case:)
          @patterns = arr.map { |source| Rx.new(source, ignore_case: ignore_case) }
        end

        def match?(values)
          values.any? { |str| @patterns.any? { |pat| pat.match?(str) } }
        end
      end

      class SingleMatching
        include MemDB::Field::Matching

        def initialize(el, ignore_case:)
          @pat = Rx.new(el, ignore_case: ignore_case)
        end

        def match?(values)
          values.any? { |str| @pat.match?(str) }
        end
      end

      attr_reader :field

      def initialize(field, ignore_case: false)
        @field = field
        @ignore_case = ignore_case
      end

      def new_matching(value)
        if value.is_a?(Array)
          MultiMatching.new(value, ignore_case: @ignore_case)
        else
          SingleMatching.new(value, ignore_case: @ignore_case)
        end
      end
    end
  end
end
