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
      @document_length_average = 0.0
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
      remove(document.fetch(:id)) if @documents[document.fetch(:id)]

      terms = @indexing_pipeline.execute(document.fetch(:indexed_field))

      @documents[document.fetch(:id)] = {
        document: document,
        number_of_terms: terms.size.to_f
      }

      @index = terms.each_with_object(@index) do |term, index|
        index[term] ||= []
        index[term] << [
          document,
          { term: term, value: Tf.calculate(term, terms) }
        ]
      end

      calculate_document_length_average
    end

    # Removes a document by id from index and documents list
    def remove(id)
      document = @documents.dig(id, :document)

      terms = @indexing_pipeline.execute(document.fetch(:indexed_field))

      terms.each do |term|
        @index[term] = @index[term].reject do |document, _tf|
          document.fetch(:id) == id
        end

        @index.delete(term) if @index[term].size == 0
      end

      removed_document = @documents.delete(id)

      calculate_document_length_average

      removed_document
    end

    def search(raw_terms, operator: 'or')
      processed_terms = @querying_pipeline.execute(raw_terms)

      # gets the documents that matches each term
      results_by_terms = processed_terms.map do |term|
        @index[term] || []
      end

      return [] unless results_by_terms.any?

      idfs = generate_idfs(processed_terms)

      # We flat and group by document id
      any_term_matched_documents = results_by_terms.flatten(1).group_by do |document, _tf|
        document.fetch(:id)
      end

      # We select documents based on operator
      # if operator AND
      #   we select only documents that matched all terms
      # else
      #   we select everthing
      operator_specific_matched_documents = any_term_matched_documents.select do |_document_id, document_and_tfs|
        match_terms_according_operator?(document_and_tfs,
                                        processed_terms,
                                        operator)
      end

      # map to a { document:, score: } structure.
      document_and_scores = operator_specific_matched_documents.map do |document_id, document_and_tfs|
        {
          document: @documents.dig(document_id, :document),
          score: calculate_score(@documents.fetch(document_id), document_and_tfs, idfs)
        }
      end

      # sort by scores and wraps in a more convenient structure.
      documents = document_and_scores
        .sort_by { |item| -item[:score] }

      { documents: documents, idfs: idfs, processed_terms: processed_terms }
    end

    def size
      @documents.size
    end

    def stats
      {
        documents: @documents.size,
        index: {
          size: @index.size,
          terms: @index.keys
        }
      }
    end

    private

    def calculate_document_length_average
      all_terms_size = @documents.values.map { |document| document[:number_of_terms].to_f }.reduce(&:+).to_f

      @document_length_average = all_terms_size.to_f / @documents.size.to_f
    end

    def match_terms_according_operator?(document_and_tfs, terms, operator)
      return true if operator == 'or'

      document_and_tfs.size == terms.size
    end

    def calculate_score(document, document_and_tfs, idfs)
      terms_scores = document_and_tfs.map do |_document, tf|
        Bm25.calculate(
          tf: tf.fetch(:value),
          idf: idfs[tf.fetch(:term)],
          document_length: document[:number_of_terms],
          document_length_average: @document_length_average
        )
      end

      terms_scores.reduce(&:+)
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
