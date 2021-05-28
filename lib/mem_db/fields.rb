# frozen_string_literal: true

class MemDB
  class Fields
    class Matching
      def initialize(fields, obj)
        @matchings = fields
          .map do |field|
            [field, field.new_matching(field.field_value(obj))]
          end
          .reject! do |_field, matching|
            matching == MemDB::Field::MayMissing::ANY_MATCHING
          end
      end

      def match?(query)
        @matchings.all? { |field, matching| matching.match?(query.field_value(field)) }
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
