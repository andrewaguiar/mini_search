require 'mini_search/version.rb'
require 'mini_search/standard_whitespace_tokenizer.rb'
require 'mini_search/strip_filter.rb'
require 'mini_search/downcase_filter.rb'
require 'mini_search/stop_words_filter.rb'
require 'mini_search/synonyms_filter.rb'
require 'mini_search/pipeline.rb'
require 'mini_search/inverted_index.rb'
require 'mini_search/tf.rb'
require 'mini_search/idf.rb'

module MiniSearch
  def self.new_index(stop_words = [], synonyms_maps = {})
    indexing_pipeline = Pipeline.new(
      StandardWhitespaceTokenizer.new,
      [
        StripFilter.new,
        DowncaseFilter.new,
        StopWordsFilter.new(stop_words)
      ]
    )

    querying_pipeline = Pipeline.new(
      StandardWhitespaceTokenizer.new,
      [
        StripFilter.new,
        DowncaseFilter.new,
        StopWordsFilter.new(stop_words),
        SynonymsFilter.new(synonyms_maps)
      ]
    )

    MiniSearch::InvertedIndex.new(indexing_pipeline, querying_pipeline)
  end
end
