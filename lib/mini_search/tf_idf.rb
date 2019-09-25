# frozen_string_literal: true

module MiniSearch
  class TfIdf
    def self.calculate(number_of_documents_with_term, number_of_documents)
      1.0 - (number_of_documents_with_term.to_f / number_of_documents.to_f)
    end
  end
end
