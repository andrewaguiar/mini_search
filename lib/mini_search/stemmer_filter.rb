# frozen_string_literal: true

module MiniSearch
  class StemmerFilter
    def initialize(stemmer)
      @stemmer = stemmer
    end

    def execute(tokens)
      return tokens unless @stemmer

      new_tokens = tokens.map do |token|
        @stemmer.stem(token)
      end

      (new_tokens + tokens).uniq
    end
  end
end
