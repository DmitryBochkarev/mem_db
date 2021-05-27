# frozen_string_literal: true

require "mem_db/idx"

class MemDB
  class IndexingObject
    def initialize
      @params = {}
      @attrs = {}
      @idx_value = {}
    end

    def assign!(params)
      @params = params
      @attrs.clear
      @idx_value.clear

      self
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
        @idx_value[idx] ||= idx.value(self)
      end
    end

    def prepare_attr(attr)
      v = @params[attr]

      if v == MemDB::Idx::ANY || v.nil? || v.is_a?(Array)
        v
      else
        [v]
      end
    end
  end
end
