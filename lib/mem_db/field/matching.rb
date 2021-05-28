# frozen_string_literal: true

class MemDB
  module Field
    module Matching
      def match?(_values)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
