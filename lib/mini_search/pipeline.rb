# frozen_string_literal: true

module MiniSearch
  # All the transformations and normalizations we need to
  # do when indexing a document or searching
  class Pipeline
    def initialize(tokenizer, filters)
      @tokenizer = tokenizer
      @filters = filters
    end

    def execute(string)
      tokens = @tokenizer.execute(string)

      @filters.reduce(tokens) do |filtered_tokens, filter|
        filter.execute(filtered_tokens)
      end
    end
  end
end
