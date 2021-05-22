# frozen_string_literal: true

require "mem_db/idx"

class MemDB
  module Idx
    class Chars
      include MemDB::Idx

      attr_reader :field

      class Chars
        include Enumerable

        def initialize(str)
          @str = str
          @length = str.length
        end

        def [](pos)
          @str[pos]
        end

        attr_reader :length

        def reverse
          ReversedChars.new(@str)
        end

        def each
          return to_enum unless block_given?

          i = 0
          while i < @length
            yield @str[i]
            i += 1
          end
        end
      end

      class ReversedChars
        include Enumerable

        def initialize(str)
          @str = str
          @length = str.length
        end

        def [](pos)
          @str[@str.length - pos - 1]
        end

        def length
          @str.length
        end

        def reverse
          Chars.new(@str)
        end

        def each
          return to_enum unless block_given?

          i = @length - 1
          while i >= 0
            yield @str[i]
            i -= 1
          end
        end
      end

      def initialize(field)
        @field = field
      end

      def map_value(raw)
        raw.chars
      end

      def map_query(text)
        Chars.new(text)
      end
    end
  end
end
