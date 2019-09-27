# frozen_string_literal: true

module MiniSearch
  # https://en.wikipedia.org/wiki/Okapi_BM25
  class Bm25
    def self.calculate(tf:, idf:, k1: 1.2, b: 0.75, document_length:, document_length_average:)
      idf * (
        (tf * (k1 + 1))
        \
        (tf + k1 * (1 - b + b * (document_length.to_f / document_length_average)))
      )
    end
  end
end
