# frozen_string_literal: true

require "mem_db/index"
require "mem_db/index/bucket"
require "mem_db/out"
require "mem_db/idx"

class MemDB
  module Index
    class Any
      include MemDB::Index

      class Bucket
        include MemDB::Index::Bucket

        def initialize(original)
          @original = original
        end

        def new
          MemDB::Index::Any.new(@original.new)
        end

        def bucket=(bucket)
          @original.bucket = bucket
        end
      end

      def initialize(original)
        raise ArgumentError, "original must be MemDB::Index, got: #{original.class}" unless original.is_a?(MemDB::Index)

        @original = original
      end

      def idx
        @original.idx
      end

      def bucket
        @original.bucket
      end

      def add(obj, value)
        addr = obj.idx_value(idx)
        if addr == MemDB::Idx::ANY
          @any ||= bucket.new
          @any.add(obj, value)
        else
          @original.add(obj, value)
        end
      end

      def query(query, out: MemDB::Out.new)
        @original.query(query, out: out)
        @any&.query(query, out: out)
        out
      end
    end
  end
end
