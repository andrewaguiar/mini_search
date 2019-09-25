# frozen_string_literal: true

module MiniSearch
  class SynonymsFilter
    def initialize(synonyms_map)
      @flatten_synonyms_map = synonyms_map.keys.each_with_object({}) do |key, hash|
        synonyms_map[key].each do |value|
          hash[value] = key
        end
      end
    end

    def execute(tokens)
      synonyms = tokens.map { |token| @flatten_synonyms_map[token] }.reject(&:nil?)

      tokens + synonyms
    end
  end
end
