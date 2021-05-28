# frozen_string_literal: true

class MemDB
  class Query
    def initialize(params)
      @params = params
      @attrs = {}
      @idx_value = {}
      @field_value = {}
    end

    def using(index)
      index.query(self)
    end

    def [](attr)
      if @attrs.key?(attr)
        @attrs[attr]
      else
        @attrs[attr] ||= prepare_attr(attr)
      end
    end

    def []=(param, value)
      @params[param] = value
    end

    def delete(param)
      @params.delete(param)
      @attrs.delete(param)
    end

    def idx_value(idx)
      if @idx_value.key?(idx)
        @idx_value[idx]
      else
        @idx_value[idx] ||= idx.prepare_query(self)
      end
    end

    def field_value(field)
      if @field_value.key?(field)
        @field_value[field]
      else
        @field_value[field] ||= field.prepare_query(self)
      end
    end

    def prepare_attr(attr)
      v = @params[attr]
      if v.is_a?(Array)
        v
      else
        [v]
      end
    end
  end
end
