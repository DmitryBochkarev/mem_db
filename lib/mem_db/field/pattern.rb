# frozen_string_literal: true

require "mem_db/field"
require "mem_db/field/matching"

class MemDB
  module Field
    class Pattern
      include MemDB::Field

      class Pattern
        WILDCARD = "*"

        class Rx
          def initialize(source)
            parts = source.split(WILDCARD, -1).map { |part| ::Regexp.quote(part) }
            parts[0] = "\\A#{parts[0]}"
            parts[-1] = "#{parts[-1]}\\z"
            @rx = ::Regexp.new(parts.join(".*"), ::Regexp::MULTILINE)
          end

          def match?(str)
            @rx.match?(str)
          end
        end

        class Exact
          def initialize(source)
            @source = source
          end

          def match?(str)
            @source == str
          end
        end

        class Prefix
          def initialize(prefix)
            @prefix = prefix
          end

          def match?(str)
            str.start_with?(@prefix)
          end
        end

        class Suffix
          def initialize(suffix)
            @suffix = suffix
          end

          def match?(str)
            str.end_with?(@suffix)
          end
        end

        def initialize(source)
          wildcard_count = source.count(WILDCARD)
          @pat =
            if wildcard_count.zero?
              Exact.new(source)
            elsif wildcard_count > 1
              Rx.new(source)
            elsif source.end_with?(WILDCARD)
              Prefix.new(source[0..-2])
            elsif source.start_with?(WILDCARD)
              Suffix.new(source[1..-1])
            else # rubocop:disable Lint/DuplicateBranch
              Rx.new(source)
            end
        end

        def match?(str)
          @pat.match?(str)
        end
      end

      class MultiMatching
        include MemDB::Field::Matching

        def initialize(arr)
          @patterns = arr.map { |source| Pattern.new(source) }
        end

        def match?(values)
          values.any? { |str| @patterns.any? { |pat| pat.match?(str) } }
        end
      end

      class SingleMatching
        include MemDB::Field::Matching

        def initialize(el)
          @pat = Pattern.new(el)
        end

        def match?(values)
          values.any? { |str| @pat.match?(str) }
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
