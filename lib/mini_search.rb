require 'yaml'
require 'mini_search/version.rb'
require 'mini_search/stemmer/portuguese.rb'
require 'mini_search/standard_whitespace_tokenizer.rb'
require 'mini_search/ngram_tokenizer.rb'
require 'mini_search/compound_tokenizer.rb'
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
require 'mini_search/bm_25.rb'

module MiniSearch
  LANGUAGE_SUPPORTS = {
    pt: MiniSearch::LanguageSupport::Portuguese
  }

  def self.new(indexing_pipeline, querying_pipeline)
    MiniSearch::InvertedIndex.new(indexing_pipeline, querying_pipeline)
  end

  def self.new_index(stop_words: [], synonyms_map: {}, stemmer: nil, ngrams: nil)
    tokenizer =
      if ngrams
        NgramTokenizer.new(ngrams)
      else
        StandardWhitespaceTokenizer.new
      end

    strip_filter = StripFilter.new
    remove_punctuation_filter = RemovePunctuationFilter.new
    downcase_filter = DowncaseFilter.new
    stop_words_filter = StopWordsFilter.new(stop_words)
    stemmer_filter = StemmerFilter.new(stemmer)
    synonyms_filter = SynonymsFilter.new(synonyms_map)

    indexing_pipeline = Pipeline.new(
      tokenizer,
      [
        strip_filter,
        remove_punctuation_filter,
        downcase_filter,
        stop_words_filter,
        stemmer_filter
      ]
    )

    querying_pipeline = Pipeline.new(
      tokenizer,
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

  def self.new_localized_index(lang, synonyms_map: {}, stop_words: [], ngrams: nil)
    language_support = find_language_support(lang, stop_words)

    new_index(
      stop_words: language_support.stop_words,
      stemmer: language_support.stemmer,
      synonyms_map: synonyms_map,
      ngrams: ngrams
    )
  end

  def self.from_config_file(file)
    raise "file not found '#{file}'" unless File.exists?(file)

    cores = YAML.load_file(file)['cores']

    cores.map do |core|
      lang = core['lang'].to_sym

      new_localized_index(
        lang,
        stop_words: core['stop_words'],
        synonyms_map: core['synonyms_map'].transform_values { |v| v.split(',') }
      )
    end
  end

  private_class_method def self.find_language_support(lang, stop_words)
    if lang.is_a?(Symbol)
      language_support = LANGUAGE_SUPPORTS[lang].new(stop_words)
    end

    raise 'language support not found or nil' unless language_support

    language_support
  end
end
