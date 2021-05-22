# frozen_string_literal: true

class MemDB
  class Bucket
    def initialize
      @values = []
    end

    def add(_obj, value)
      @values.push(value)
    end

    def query(_query, out:)
      out.add(@values)
    end
  end
end
