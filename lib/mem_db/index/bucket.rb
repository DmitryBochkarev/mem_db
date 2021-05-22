# frozen_string_literal: true

# TODO: move to mem_db/index.rb
class MemDB
  module Index
    module Bucket
      def new
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def bucket=(bucket)
        @bucket = bucket
      end

      def accept_any
        MemDB::Index::Any::Bucket.new(self)
      end
    end
  end
end
