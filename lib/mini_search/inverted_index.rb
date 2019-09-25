# frozen_string_literal: true

module MiniSearch
  # Very simple and naive in-memory search engine
  # implements an inverted index
  class InvertedIndex
    def initialize(indexing_pipeline, querying_pipeline)
      @indexing_pipeline = indexing_pipeline
      @querying_pipeline = querying_pipeline
      @documents = {}
      @index = {}
    end

    # Index a document, documents are simply Hashs with at least
    #
    # {
    #   id: 'unique_id',
    #   indexed_field: 'text field',
    #   ...
    # }
    #
    def index(document)
      @documents[document.fetch(:id)] = document

      terms = @indexing_pipeline.execute(document.fetch(:indexed_field))

      @index = terms.each_with_object(@index) do |term, index|
        index[term] ||= []
        index[term] << [
          document,
          { term: term, value: Tf.calculate(term, terms) }
        ]
      end
    end

    def search(raw_terms)
      processed_terms = @querying_pipeline.execute(raw_terms)

      # gets the documents that matches each term
      results_by_terms = processed_terms.map do |term|
        @index[term] || []
      end

      return [] unless results_by_terms.any?

      idfs = generate_idfs(processed_terms)

      # For each document we calculate the score based on
      # how many terms the document matched (the higher the best)
      documents = results_by_terms
        .flatten(1)
        .group_by { |document, _tf| document.fetch(:id) }
        .map { |document_id, documents| [@documents.fetch(document_id), calculate_score(documents, idfs)] }
        .sort_by { |_document, score| -score }
        .map { |document, score| { document: document, score: score } }
    end

    private

    def calculate_score(documents, idfs)
      tf_idf = documents
        .map { |_document, tf| tf.fetch(:value) * idfs[tf.fetch(:term)] }
        .reduce(&:+)
    end

    def generate_idfs(processed_terms)
      processed_terms.each_with_object({}) do |term, idfs|
        if @index[term].to_a.any?
          idfs[term] = Idf.calculate(@index[term].size, @documents.size)
        end
      end
    end
  end
end
