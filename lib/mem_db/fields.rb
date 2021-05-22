# frozen_string_literal: true

class MemDB
  class Fields
    class Matching
      def initialize(fields, obj)
        @matchings = fields.map { |field| field.new_matching(obj) }.reject! do |matching|
          matching == MemDB::Field::MayMissing::ANY_MATCHING
        end
      end

      def match?(query)
        @matchings.all? { |matching| matching.match?(query) }
      end
    end

    def initialize(fields)
      @fields = fields
    end

    def new_matching(obj)
      Matching.new(@fields, obj)
    end
  end
end
