# frozen_string_literal: true

require "mem_db/out"
require "mem_db/index"
require "mem_db/index/bucket"
require "mem_db/bucket"

class MemDB
  module Index
    class Enum
      include MemDB::Index

      class Bucket
        include MemDB::Index::Bucket

        def initialize(idx:, bucket: MemDB::Bucket)
          @idx = idx
          @bucket = bucket
        end

        def new
          MemDB::Index::Enum.new(idx: @idx, bucket: @bucket)
        end
      end

      attr_reader :idx, :bucket

      def initialize(idx:, bucket: MemDB::Bucket)
        @idx = idx
        @bucket = bucket
        @hash = {}
      end

      def add(obj, value)
        enums = obj.idx_value(@idx)
        enums.each do |enum|
          b = @hash[enum] ||= @bucket.new
          b.add(obj, value)
        end
      end

      def query(query, out: MemDB::Out.new)
        enums = query.idx_value(@idx)
        enums.each do |enum|
          if (b = @hash[enum])
            b.query(query, out: out)
          end
        end

        out
      end
    end
  end
end
