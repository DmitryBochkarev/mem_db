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
            else
              Rx.new(source)
            end
        end

        def match?(str)
          @pat.match?(str)
        end
      end

      class MultiMatching
        include MemDB::Field::Matching

        def initialize(f, arr)
          @f = f
          @patterns = arr.map { |source| Pattern.new(source) }
        end

        def match?(query)
          @f.query_value(query).each do |str|
            return true if @patterns.any? { |pat| pat.match?(str) }
          end

          false
        end
      end

      class SingleMatching
        include MemDB::Field::Matching

        def initialize(f, el)
          @f = f
          @pat = Pattern.new(el)
        end

        def match?(query)
          @f.query_value(query).any? { |str| @pat.match?(str) }
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
