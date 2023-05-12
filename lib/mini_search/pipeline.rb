# frozen_string_literal: true

module MiniSearch
  # All the transformations and normalizations we need to
  # do when indexing a document or searching
  class Pipeline
    def initialize(tokenizer, filters)
      @standard_tokenizer = MiniSearch::StandardWhitespaceTokenizer.new
      @tokenizer = tokenizer
      @filters = filters
    end

    def execute(string)
      # Since the filter model expects tokens that are tokenized by
      # the standard tokenizer, let's use that first.
      tokens = @standard_tokenizer.execute(string)

      # Apply filters
      filters_applied = @filters.reduce(tokens) do |filtered_tokens, filter|
        filter.execute(filtered_tokens)
      end

      # Return if our selected tokenizer is the standard tokenizer
      return filters_applied if @tokenizer.is_a? MiniSearch::StandardWhitespaceTokenizer

      # Execute non-standard tokenization after rejoining the tokens
      # that were tokenized with the StandardWhitespaceTokenizer
      @tokenizer.execute(filters_applied.join(' '))
    end
  end
end
