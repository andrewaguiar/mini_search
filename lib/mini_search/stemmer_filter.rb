# frozen_string_literal: true

module MiniSearch
  class StemmerFilter
    def initialize(stemmer)
      @stemmer = stemmer
    end

    def execute(tokens)
      return tokens unless @stemmer

      tokens.map do |token|
        @stemmer.stem(token)
      end
    end
  end
end
