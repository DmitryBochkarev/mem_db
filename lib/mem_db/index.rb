# frozen_string_literal: true

require "mem_db/out"

class MemDB
  module Index
    def self.compose(chain)
      (0..chain.length - 2).each do |parent_i|
        chain[parent_i].bucket = chain[parent_i + 1]
      end
      chain[0].new
    end

    def idx
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def bucket
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def add(_obj, _value)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def query(_query, out: MemDB::Out.new)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
    # rubocop:enable Lint/UnusedMethodArgument
  end
end
