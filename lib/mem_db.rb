# frozen_string_literal: true

require_relative "mem_db/version"
require "set"

class MemDB
  class Error < StandardError; end

  class Entries
    class Entry
      attr_reader :id, :matching, :value

      def initialize(id, matching, value)
        @id = id
        @matching = matching
        @value = value
      end
    end

    def initialize
      @entries = []
    end

    def [](id)
      @entries[id]
    end

    def add(matching, value)
      id = @entries.length

      entry = Entry.new(id, matching, value)
      @entries.push(entry)

      id
    end
  end

  def initialize(fields, index)
    @fields = fields
    @index = index
    @entries = Entries.new
  end

  def new_indexation
    MemDB::Indexation.new(self)
  end

  def add(obj, value)
    matching = @fields.new_matching(obj)
    entry_id = @entries.add(matching, value)

    @index.add(obj, entry_id)
  end

  def query(query)
    checked = Set.new
    found = []

    @index.query(query).each do |entry_id|
      next if checked.include?(entry_id)

      checked.add(entry_id)

      entry = @entries[entry_id]

      found.push(entry.value) if entry.matching.match?(query)
    end

    found
  end
end

require_relative "mem_db/out"
require_relative "mem_db/idx"
require_relative "mem_db/query"
require_relative "mem_db/indexing_object"
require_relative "mem_db/indexation"
require_relative "mem_db/index"
require_relative "mem_db/fields"
require_relative "mem_db/field"

require_relative "mem_db/idx/bytes"
require_relative "mem_db/idx/chars"
require_relative "mem_db/idx/itself"
require_relative "mem_db/idx/reverse"
require_relative "mem_db/idx/uniq"
require_relative "mem_db/idx/pattern"
require_relative "mem_db/idx/default"
require_relative "mem_db/idx/downcase"

require_relative "mem_db/index/bucket"
require_relative "mem_db/index/any"
require_relative "mem_db/index/enum"
require_relative "mem_db/index/prefix_tree"
require_relative "mem_db/index/sequence_match"
require_relative "mem_db/index/pattern_match"

require_relative "mem_db/field/matching"
require_relative "mem_db/field/may_missing"
require_relative "mem_db/field/negative"
require_relative "mem_db/field/enum"
require_relative "mem_db/field/pattern"
require_relative "mem_db/field/regexp"
require_relative "mem_db/field/downcase"
