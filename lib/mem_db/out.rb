# frozen_string_literal: true

class MemDB
  class Out
    include Enumerable

    def initialize
      @arr = []
    end

    def add(res)
      @arr.push(res)

      true
    end

    def each(&block)
      return to_enum unless block_given?

      @arr.each do |values|
        values.each(&block)
      end
    end
  end
end
