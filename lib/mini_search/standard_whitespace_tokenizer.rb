# frozen_string_literal: true

module MiniSearch
  class StandardWhitespaceTokenizer
    def execute(string)
      string.strip.split(' ')
    end
  end
end
