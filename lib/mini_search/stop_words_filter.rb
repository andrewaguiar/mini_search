# frozen_string_literal: true

module MiniSearch
  class StopWordsFilter
    def initialize(stop_words)
      @stop_words = stop_words
    end

    def execute(tokens)
      tokens.reject { |token| @stop_words.include?(token) }
    end
  end
end
