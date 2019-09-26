# frozen_string_literal: true

module MiniSearch
  class Idf
    def self.calculate(number_of_documents_with_term, number_of_documents)
      Math.log(number_of_documents.to_f / number_of_documents_with_term.to_f)
    end
  end
end
