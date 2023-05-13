# frozen_string_literal: true

module MiniSearch
  class CompoundTokenizer
    def initialize(tokenizers)
      @tokenizers = tokenizers
    end

    def execute(string)
      @tokenizers.each_with_object([]) do |tokenizer, tokens|
        tokens.concat(tokenizer.execute(string))
      end
    end
  end
end
