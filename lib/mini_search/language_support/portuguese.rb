module MiniSearch
  module LanguageSupport
    class Portuguese
      attr_reader :stemmer, :stop_words

      def initialize(stop_words = [])
        @stemmer = ::MiniSearch::Stemmer::Portuguese.new
        @stop_words = %w[
          a á à ainda alem ambas ambos antes ao aonde aos apos aquele aqueles as assim com como contra contudo cuja cujas cujo cujos da
          das de dela dele deles demais depois desde desta deste dispoe dispoem diversa diversas diversos do dos durante e é ela elas
          ele eles em entao entre essa essas esse esses esta estas este estes ha isso isto logo mais mas mediante menos mesma mesmas mesmo
          mesmos na nas nao nas nem nesse neste nos o os ou outra outras outro outros pela pelas pelas pelo pelos perante pois por porque portanto
          proprio quais qual qualquer quando quanto que quem quer se seja sem sendo seu seus sob sobre sua suas tal tambem teu
          teus toda todas todo todos tua tuas tudo um uma umas uns
        ] + stop_words
      end
    end
  end
end
