require 'mini_search/version.rb'
require 'mini_search/stemmer/portuguese.rb'
require 'mini_search/standard_whitespace_tokenizer.rb'
require 'mini_search/strip_filter.rb'
require 'mini_search/remove_punctuation_filter.rb'
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
  LANGUAGE_SUPPORTS = {
    pt: MiniSearch::LanguageSupport::Portuguese
  }

  def self.new(indexing_pipeline, querying_pipeline)
    MiniSearch::InvertedIndex.new(indexing_pipeline, querying_pipeline)
  end

  def self.new_index(stop_words: [], synonyms_map: {}, stemmer: nil)
    standard_whitespace_tokenizer = StandardWhitespaceTokenizer.new

    strip_filter = StripFilter.new
    remove_punctuation_filter = RemovePunctuationFilter.new
    downcase_filter = DowncaseFilter.new
    stop_words_filter = StopWordsFilter.new(stop_words)
    stemmer_filter = StemmerFilter.new(stemmer)
    synonyms_filter = SynonymsFilter.new(synonyms_map)

    indexing_pipeline = Pipeline.new(
      standard_whitespace_tokenizer,
      [
        strip_filter,
        remove_punctuation_filter,
        downcase_filter,
        stop_words_filter,
        stemmer_filter
      ]
    )

    querying_pipeline = Pipeline.new(
      standard_whitespace_tokenizer,
      [
        strip_filter,
        remove_punctuation_filter,
        downcase_filter,
        stop_words_filter,
        stemmer_filter,
        synonyms_filter
      ]
    )

    new(indexing_pipeline, querying_pipeline)
  end

  def self.new_localized_index(language_support, synonyms_map: {}, stop_words: [])
    if language_support.is_a?(Symbol)
      language_support = LANGUAGE_SUPPORTS[language_support].new(stop_words)
    end

    raise 'language support not found or nil' unless language_support

    new_index(
      stop_words: language_support.stop_words,
      stemmer: language_support.stemmer,
      synonyms_map: synonyms_map
    )
  end
end
