# frozen_string_literal: true

class MemDB
  module Field
    def may_missing
      MemDB::Field::MayMissing.new(self)
    end

    def negative
      MemDB::Field::Negative.new(self)
    end

    def downcase
      MemDB::Field::Downcase.new(self)
    end

    def field
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def query(query_field)
      @query_field = query_field
      self
    end

    def query_field
      @query_field || field
    end

    def new_matching(_value)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def field_value(obj)
      obj[field]
    end

    def prepare_query(query)
      query[query_field]
    end
  end
end
