# frozen_string_literal: true

require "mem_db/out"
require "mem_db/index"
require "mem_db/index/bucket"
require "mem_db/bucket"

class MemDB
  module Index
    class PrefixTree
      include MemDB::Index

      class Bucket
        include MemDB::Index::Bucket

        def initialize(idx:, bucket: MemDB::Bucket)
          @idx = idx
          @bucket = bucket
        end

        def new
          MemDB::Index::PrefixTree.new(idx: @idx, bucket: @bucket)
        end
      end

      class Root
        MAX_LENGTH_DEFAULT = 2 ^ 64

        def initialize(bucket:)
          @item = Item.new(bucket: bucket)
          @min_length = MAX_LENGTH_DEFAULT
        end

        def get(contents, query:, result:)
          contents.each do |content|
            next if @min_length > content.length

            @item.select_values(content, 0, query: query, out: result)
          end

          result
        end

        def add(prefixes, obj, value)
          prefixes.each do |prefix|
            @min_length = prefix.length if @min_length > prefix.length
            @item.add(prefix, 0, obj, value)
          end
        end
      end

      class Item
        attr_reader :value

        def initialize(bucket:)
          @bucket = bucket
        end

        def select_values(content, i, query:, out:)
          @value&.query(query, out: out)

          return if content.length == i

          return unless @children

          if (item = @children[content[i]])
            item.select_values(content, i + 1, query: query, out: out)
          end
        end

        def add(prefix, i, obj, value)
          if prefix.length == i
            set_value(obj, value)
          else
            item = fetch_children(prefix[i])
            item.add(prefix, i + 1, obj, value)
          end
        end

        def set_value(obj, value)
          @value ||= @bucket.new
          @value.add(obj, value)
        end

        def fetch_children(idx)
          @children ||= {}
          @children[idx] ||= Item.new(bucket: @bucket)
        end
      end

      attr_reader :idx, :bucket

      def initialize(idx:, bucket: MemDB::Bucket)
        @idx = idx
        @bucket = bucket
        @root = Root.new(bucket: bucket)
      end

      def add(obj, value)
        @root.add(obj.idx_value(@idx), obj, value)
      end

      def query(query, out: MemDB::Out.new)
        @root.get(query.idx_value(@idx), query: query, result: out)

        out
      end
    end
  end
end
