# frozen_string_literal: true

module MiniSearch
  class RemovePunctuationFilter
    def execute(tokens)
      tokens.map do |token|
        token.tr(',.!;:', '')
      end
    end
  end
end
