# frozen_string_literal: true

class MemDB
  module Idx
    class Pattern
      include MemDB::Idx

      class Pattern
        def initialize(source, min:)
          @parts = source.split("*", -1)
          @min = min
        end

        def value # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity
          if @parts.length == 1
            [:enum, @parts[0]]
          else
            prefix = @parts[0]
            suffix = @parts[-1]

            if prefix != "" || suffix != ""
              if prefix.length >= @min && prefix.length >= suffix.length
                [:prefix, prefix]
              elsif suffix.length >= @min
                [:suffix, suffix]
              else
                candidates = [
                  [:prefix, prefix],
                  [:suffix, suffix]
                ]

                candidates.push([:substring, substring]) if substring # rubocop:disable Metrics/BlockNesting

                candidates.max_by { |v| v[1].length }
              end
            else
              [:substring, substring]
            end
          end
        end

        private

        def substring
          return @substring if defined?(@substring)

          @substring =
            if @parts.length > 2
              substrings = @parts[1..-2]
              substrings.find { |p| p.length > @min } || substrings.find { |p| p.length.positive? }
            end
        end
      end

      attr_reader :field

      def initialize(field, min: 3)
        @field = field
        @min = min
      end

      def map_value(pattern)
        Pattern.new(pattern, min: @min).value
      end

      def map_query(text)
        text
      end
    end
  end
end
