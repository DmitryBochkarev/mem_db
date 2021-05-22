# frozen_string_literal: true

require "mem_db/index"
require "mem_db/index/bucket"
require "mem_db/out"

class MemDB
  module Index
    class SequenceMatch
      include MemDB::Index

      class Bucket
        include MemDB::Index::Bucket

        def initialize(idx:, bucket: MemDB::Bucket)
          @idx = idx
          @bucket = bucket
        end

        def new
          MemDB::Index::SequenceMatch.new(idx: @idx, bucket: @bucket)
        end
      end

      # https://en.wikipedia.org/wiki/Boyer-Moore_string_search_algorithm
      class SequenceIndex
        def initialize(pattern)
          @pattern = pattern
          @pattern_length = pattern.length
          @bad_char_skip = {}
          @good_suffix_skip = Array.new(@pattern_length, 0)

          init_tables
        end

        def index(seq)
          i = @pattern_length - 1

          while i < seq.length
            j = @pattern_length - 1

            while j >= 0 && seq[i] == @pattern[j]
              i -= 1
              j -= 1
            end

            return i + 1 if j.negative?

            bad_skip = @bad_char_skip[seq[i]] || @pattern_length
            good_skip = @good_suffix_skip[j]
            i += good_skip > bad_skip ? good_skip : bad_skip
          end

          -1
        end

        def init_tables # rubocop:disable Metrics/AbcSize
          last = @pattern_length - 1

          i = 0
          while i < last
            @bad_char_skip[@pattern[i]] = last - i
            i += 1
          end

          last_prefix = last

          i = last
          while i >= 0
            last_prefix = i + 1 if pattern_suffix?(i + 1)

            @good_suffix_skip[i] = last_prefix + last - i
            i -= 1
          end

          i = 0
          while i < last
            len_suffix = longest_pattern_suffix(i)

            if @pattern[i - len_suffix] != @pattern[last - len_suffix]
              @good_suffix_skip[last - len_suffix] = len_suffix + last - i
            end

            i += 1
          end
        end

        def pattern_suffix?(pos)
          i = 0
          while i + pos < @pattern.length
            return false if @pattern[i] != @pattern[i + pos]

            i += 1
          end
          true
        end

        def longest_pattern_suffix(pos)
          i = 0

          while i < @pattern.length && i < pos
            break if @pattern[@pattern.length - 1 - i] != @pattern[pos - i]

            i += 1
          end

          i
        end
      end

      def initialize(idx:, bucket: MemDB::Bucket)
        @idx = idx
        @bucket = bucket
        @patterns = {}
        @matchers = {}
      end

      def add(obj, value)
        obj.idx_value(@idx).each do |pattern|
          @patterns[pattern] ||= @bucket.new
          @patterns[pattern].add(obj, value)

          @matchers[pattern] ||= SequenceIndex.new(pattern)
        end
      end

      def query(query, out: MemDB::Out.new)
        query.idx_value(@idx).each do |seq|
          select_one(query, seq, out)
        end

        out
      end

      private

      def select_one(query, seq, out)
        @matchers.each do |pattern, sequence|
          next if seq.length < pattern.length

          @patterns[pattern].query(query, out: out) if sequence.index(seq) > -1
        end
      end
    end
  end
end
