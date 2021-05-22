# frozen_string_literal: true

require "mem_db/index/enum"
require "mem_db/index/prefix_tree"
require "mem_db/index/sequence_match"
require "mem_db/bucket"
require "mem_db/index/bucket"
require "mem_db/out"

class MemDB
  module Index
    class PatternMatch
      include MemDB::Index

      class Bucket
        include MemDB::Index::Bucket

        def initialize(idx:, bucket: MemDB::Bucket)
          @idx = idx
          @bucket = bucket
        end

        def new
          MemDB::Index::PatternMatch.new(idx: @idx, bucket: @bucket)
        end
      end

      attr_reader :idx, :bucket

      def initialize(idx:, bucket: MemDB::Bucket)
        @idx = idx
        @bucket = bucket
      end

      def add(obj, value)
        obj.idx_value(@idx).each do |pattern|
          type = pattern[0]
          sequence = pattern[1]
          index =
            case type
            when :enum
              enums
            when :prefix
              prefixes
            when :suffix
              suffixes
            when :substring
              substrings
            end

          obj[self] = sequence
          index.add(obj, value)
          obj.delete(self)
        end
      end

      def query(query, out: MemDB::Out.new)
        query.idx_value(@idx).each do |q|
          query[self] = q

          @enums&.query(query, out: out)
          @suffixes&.query(query, out: out)
          @prefixes&.query(query, out: out)
          @substrings&.query(query, out: out)

          query.delete(self)
        end

        out
      end

      private

      def enums
        @enums ||= MemDB::Index::Enum.new(
          idx: MemDB::Idx::Itself.new(self),
          bucket: @bucket
        )
      end

      def prefixes
        @prefixes ||= MemDB::Index::PrefixTree.new(
          idx: MemDB::Idx::Bytes.new(self),
          bucket: @bucket
        )
      end

      def suffixes
        @suffixes ||= MemDB::Index::PrefixTree.new(
          idx: MemDB::Idx::Reverse.new(MemDB::Idx::Bytes.new(self)),
          bucket: @bucket
        )
      end

      def substrings
        @substrings ||= MemDB::Index::SequenceMatch.new(
          # reverse somehow make it faster
          idx: MemDB::Idx::Reverse.new(MemDB::Idx::Bytes.new(self)),
          bucket: @bucket
        )
      end
    end
  end
end
