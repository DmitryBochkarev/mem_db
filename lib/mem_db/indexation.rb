# frozen_string_literal: true

require "mem_db/indexing_object"

class MemDB
  class Indexation
    def initialize(index)
      @obj = MemDB::IndexingObject.new
      @index = index
    end

    def add(raw, value)
      @obj.assign!(raw)
      @index.add(@obj, value)
    end
  end
end
