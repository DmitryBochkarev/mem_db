# frozen_string_literal: true

class MemDB
  module Idx
    ANY = Object.new

    def default(default)
      MemDB::Idx::Default.new(self, default)
    end

    def default_any
      default(MemDB::Idx::ANY)
    end

    def field
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def map_value(_obj)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def map_query(_obj)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def value(obj)
      v = obj[field]

      if v == ANY
        v
      else
        v.map { |e| map_value(e) }
      end
    end

    def prepare_query(query)
      query[field].map { |v| map_query(v) }
    end
  end
end
