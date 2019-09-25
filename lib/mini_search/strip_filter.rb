# frozen_string_literal: true

module MiniSearch
  class StripFilter
    def execute(tokens)
      tokens.map(&:strip)
    end
  end
end
