# frozen_string_literal: true

module MiniSearch
  class Tf
    def self.calculate(token, terms)
      terms.count(token).to_f / terms.size.to_f
    end
  end
end
