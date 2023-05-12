# frozen_string_literal: true
require "ruby_ngrams"

module MiniSearch
  class NgramTokenizer
    def initialize(n)
      n ||= 2
      @n = n
    end
    def execute(string)
      # In the future, we may want to consider doing a strip on tokens to remove
      # whitespace.
      string.ngrams(regex: //, n: @n).map(&:join)
    end
  end
end
