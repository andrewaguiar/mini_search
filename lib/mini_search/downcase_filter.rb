# frozen_string_literal: true

module MiniSearch
  class DowncaseFilter
    def execute(tokens)
      tokens.map(&:downcase)
    end
  end
end
