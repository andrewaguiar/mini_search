require 'mini_search/version.rb'
require 'mini_search/stemmer/portuguese.rb'
require 'mini_search/standard_whitespace_tokenizer.rb'
require 'mini_search/strip_filter.rb'
require 'mini_search/downcase_filter.rb'
require 'mini_search/stop_words_filter.rb'
require 'mini_search/synonyms_filter.rb'
require 'mini_search/stemmer_filter.rb'
require 'mini_search/language_support/portuguese.rb'
require 'mini_search/pipeline.rb'
require 'mini_search/inverted_index.rb'
require 'mini_search/tf.rb'
require 'mini_search/idf.rb'

module MiniSearch
  def self.new_index(stop_words: [], synonyms_map: {}, stemmer: nil)
    indexing_pipeline = Pipeline.new(
      StandardWhitespaceTokenizer.new,
      [
        StripFilter.new,
        DowncaseFilter.new,
        StopWordsFilter.new(stop_words),
        StemmerFilter.new(stemmer)
      ]
    )

    querying_pipeline = Pipeline.new(
      StandardWhitespaceTokenizer.new,
      [
        StripFilter.new,
        DowncaseFilter.new,
        StopWordsFilter.new(stop_words),
        StemmerFilter.new(stemmer),
        SynonymsFilter.new(synonyms_map)
      ]
    )

    MiniSearch::InvertedIndex.new(indexing_pipeline, querying_pipeline)
  end

  def self.new_localized_index(language_support: nil, synonyms_map: {})
    indexing_pipeline = Pipeline.new(
      StandardWhitespaceTokenizer.new,
      [
        StripFilter.new,
        DowncaseFilter.new,
        StopWordsFilter.new(language_support.stop_words),
        StemmerFilter.new(language_support.stemmer)
      ]
    )

    querying_pipeline = Pipeline.new(
      StandardWhitespaceTokenizer.new,
      [
        StripFilter.new,
        DowncaseFilter.new,
        StopWordsFilter.new(language_support.stop_words),
        StemmerFilter.new(language_support.stemmer),
        SynonymsFilter.new(synonyms_map)
      ]
    )

    MiniSearch::InvertedIndex.new(indexing_pipeline, querying_pipeline)
  end
end
