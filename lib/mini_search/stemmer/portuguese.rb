module MiniSearch
  module Stemmer
    # Implementation of the algorithm for the RSLP Stemmer which was presented by the paper 
    # 'A Stemming Algorithm for the Portuguese Language'.
    #
    # In Proceedings of the SPIRE Conference, Laguna de San Raphael, Chile, November 13-15, 2001,
    # written by Viviane Moreira Orengo and Christian Huyck.
    #
    # More info: http://www.inf.ufrgs.br/~viviane/rslp/index.htm
    # Datasets got from: https://www.kaggle.com/nltkdata/rslp-stemmer
    #
    class Portuguese
      def initialize
        @rules_sets = {
          'plural_reduction' => plural_reduction,
          'feminine_reduction' => feminine_reduction,
          'augmentative_diminutive_reduction' => augmentative_diminutive_reduction,
          'adverb_reduction' => adverb_reduction,
          'noun_suffix_reduction' => noun_suffix_reduction,
          'verb_suffix_reduction' => verb_suffix_reduction,
          'vowel_removal' => vowel_removal
        }
      end

      def stem(word)
        if word.end_with?('s')
          word = apply_rule('plural_reduction', word)
        end

        if word.end_with?('a')
          word = apply_rule('feminine_reduction', word)
        end

        word = apply_rule('augmentative_diminutive_reduction', word)

        word = apply_rule('adverb_reduction', word)

        prev_word = word
        word = apply_rule('noun_suffix_reduction', word)

        if word == prev_word
          prev_word = word
          word = apply_rule('verb_suffix_reduction', word)

          if word == prev_word
            word = apply_rule('vowel_removal', word)
          end
        end

        word
      end

      private

      def apply_rule(rule_name, word)
        @rules_sets[rule_name].each do |rule|
          suffix            = rule[0]
          min_suffix_length = rule[1]
          replacement       = rule[2]
          exceptions        = rule[3]

          # next unless suffix matches
          next unless word.end_with?(suffix)

          # next unless we have minimum size
          next unless word.length >= suffix.length + min_suffix_length

          # next if word is an exception
          next if exceptions.include?(word)

          word = "#{word[0, word.length - suffix.length]}#{replacement}"

          break
        end

        word
      end

      def format_rules(rules)
        rules.map do |rule|
          [
            rule[0],
            rule[1].to_i,
            rule[2],
            (rule[3] == '*' ? [] : rule[3].split(','))
          ]
        end
      end

      def plural_reduction
        format_rules [
          ['ns', '1', 'm', '*'],
          ['ões', '3', 'ão', '*'],
          ['ães', '1', 'ão', 'mãe'],
          ['ais', '1', 'al', 'cais,mais'],
          ['éis', '2', 'el', '*'],
          ['eis', '2', 'el', '*'],
          ['óis', '2', 'ol', '*'],
          ['is', '2', 'il', 'lápis,cais,mais,crúcis,biquínis,pois,depois,dois,leis'],
          ['les', '3', 'l', '*'],
          ['res', '3', 'r', 'árvores'],
          ['s', '2', '', 'aliás,pires,lápis,cais,mais,mas,menos,férias,fezes,pêsames,crúcis,gás,atrás,moisés,através,convés,ês,país,após,ambas,ambos,messias,depois']
        ]
      end

      def feminine_reduction
        format_rules [
          ['ona', '3', 'ão', 'abandona,lona,iona,cortisona,monótona,maratona,acetona,detona,carona'],
          ['ora', '3', 'or', '*'],
          ['na', '4', 'no', 'carona,abandona,lona,iona,cortisona,monótona,maratona,acetona,detona,guiana,campana,grana,caravana,banana,paisana'],
          ['inha', '3', 'inho', 'rainha,linha,minha'],
          ['esa', '3', 'ês', 'mesa,obesa,princesa,turquesa,ilesa,pesa,presa'],
          ['osa', '3', 'oso', 'mucosa,prosa'],
          ['íaca', '3', 'íaco', '*'],
          ['ica', '3', 'ico', 'dica'],
          ['ada', '2', 'ado', 'pitada'],
          ['ida', '3', 'ido', 'vida'],
          ['ída', '3', 'ido', 'recaída,saída,dúvida'],
          ['ima', '3', 'imo', 'vítima'],
          ['iva', '3', 'ivo', 'saliva,oliva'],
          ['eira', '3', 'eiro', 'beira,cadeira,frigideira,bandeira,feira,capoeira,barreira,fronteira,besteira,poeira'],
          ['ã', '2', 'ão', 'amanhã,arapuã,fã,divã']
        ]
      end

      def adverb_reduction
        format_rules [
          ['mente', '4', '', 'experimente']
        ]
      end

      def augmentative_diminutive_reduction
        format_rules [
          ['díssimo', '5', '', '*'],
          ['abilíssimo', '5', '', '*'],
          ['íssimo', '3', '', '*'],
          ['ésimo', '3', '', '*'],
          ['érrimo', '4', '', '*'],
          ['zinho', '2', '', '*'],
          ['quinho', '4', 'c', '*'],
          ['uinho', '4', '', '*'],
          ['adinho', '3', '', '*'],
          ['inho', '3', '', 'caminho,cominho'],
          ['alhão', '4', '', '*'],
          ['uça', '4', '', '*'],
          ['aço', '4', '', 'antebraço'],
          ['aça', '4', '', '*'],
          ['adão', '4', '', '*'],
          ['idão', '4', '', '*'],
          ['ázio', '3', '', 'topázio'],
          ['arraz', '4', '', '*'],
          ['zarrão', '3', '', '*'],
          ['arrão', '4', '', '*'],
          ['arra', '3', '', '*'],
          ['zão', '2', '', 'coalizão'],
          ['ão', '3', '', 'camarão,chimarrão,canção,coração,embrião,grotão,glutão,ficção,fogão,feição,furacão,gamão,lampião,leão,macacão,nação,órfão,orgão,patrão,portão,quinhão,rincão,tração,falcão,espião,mamão,folião,cordão,aptidão,campeão,colchão,limão,leilão,melão,barão,milhão,bilhão,fusão,cristão,ilusão,capitão,estação,senão']
        ]
      end

      def noun_suffix_reduction
        format_rules [
          ['encialista', '4', '', '*'],
          ['alista', '5', '', '*'],
          ['agem', '3', '', 'coragem,chantagem,vantagem,carruagem'],
          ['iamento', '4', '', '*'],
          ['amento', '3', '', 'firmamento,fundamento,departamento'],
          ['imento', '3', '', '*'],
          ['mento', '6', '', 'firmamento,elemento,complemento,instrumento,departamento'],
          ['alizado', '4', '', '*'],
          ['atizado', '4', '', '*'],
          ['tizado', '4', '', 'alfabetizado'],
          ['izado', '5', '', 'organizado,pulverizado'],
          ['ativo', '4', '', 'pejorativo,relativo'],
          ['tivo', '4', '', 'relativo'],
          ['ivo', '4', '', 'passivo,possessivo,pejorativo,positivo'],
          ['ado', '2', '', 'grado'],
          ['ido', '3', '', 'cândido,consolido,rápido,decido,tímido,duvido,marido'],
          ['ador', '3', '', '*'],
          ['edor', '3', '', '*'],
          ['idor', '4', '', 'ouvidor'],
          ['dor', '4', '', 'ouvidor'],
          ['sor', '4', '', 'assessor'],
          ['atoria', '5', '', '*'],
          ['tor', '3', '', 'benfeitor,leitor,editor,pastor,produtor,promotor,consultor'],
          ['or', '2', '', 'motor,melhor,redor,rigor,sensor,tambor,tumor,assessor,benfeitor,pastor,terior,favor,autor'],
          ['abilidade', '5', '', '*'],
          ['icionista', '4', '', '*'],
          ['cionista', '5', '', '*'],
          ['ionista', '5', '', '*'],
          ['ionar', '5', '', '*'],
          ['ional', '4', '', '*'],
          ['ência', '3', '', '*'],
          ['ância', '4', '', 'ambulância'],
          ['edouro', '3', '', '*'],
          ['queiro', '3', 'c', '*'],
          ['adeiro', '4', '', 'desfiladeiro'],
          ['eiro', '3', '', 'desfiladeiro,pioneiro,mosteiro'],
          ['uoso', '3', '', '*'],
          ['oso', '3', '', 'precioso'],
          ['alizaç', '5', '', '*'],
          ['atizaç', '5', '', '*'],
          ['tizaç', '5', '', '*'],
          ['izaç', '5', '', 'organizaç'],
          ['aç', '3', '', 'equaç,relaç'],
          ['iç', '3', '', 'eleição'],
          ['ário', '3', '', 'voluntário,salário,aniversário,diário,lionário,armárioatório,3rio,5,,voluntário,salário,aniversário,diário,compulsório,lionário,próprio,stério,armário'],
          ['ério', '6', '', '*'],
          ['ês', '4', '', '*'],
          ['eza', '3', '', '*'],
          ['ez', '4', '', '*'],
          ['esco', '4', '', '*'],
          ['ante', '2', '', 'gigante,elefante,adiante,possante,instante,restaurante'],
          ['ástico', '4', '', 'eclesiástico'],
          ['alístico', '3', '', '*'],
          ['áutico', '4', '', '*'],
          ['êutico', '4', '', '*'],
          ['tico', '3', '', 'político,eclesiástico,diagnostico,prático,doméstico,diagnóstico,idêntico,alopático,artístico,autêntico,eclético,crítico,critico'],
          ['ico', '4', '', 'tico,público,explico'],
          ['ividade', '5', '', '*'],
          ['idade', '4', '', 'autoridade,comunidade'],
          ['oria', '4', '', 'categoria'],
          ['encial', '5', '', '*'],
          ['ista', '4', '', '*'],
          ['auta', '5', '', '*'],
          ['quice', '4', 'c', '*'],
          ['ice', '4', '', 'cúmplice'],
          ['íaco', '3', '', '*'],
          ['ente', '4', '', 'freqüente,alimente,acrescente,permanente,oriente,aparente'],
          ['ense', '5', '', '*'],
          ['inal', '3', '', '*'],
          ['ano', '4', '', '*'],
          ['ável', '2', '', 'afável,razoável,potável,vulnerável'],
          ['ível', '3', '', 'possível'],
          ['vel', '5', '', 'possível,vulnerável,solúvel'],
          ['bil', '3', 'vel', '*'],
          ['ura', '4', '', 'imatura,acupuntura,costura'],
          ['ural', '4', '', '*'],
          ['ual', '3', '', 'bissexual,virtual,visual,pontual'],
          ['ial', '3', '', '*'],
          ['al', '4', '', 'afinal,animal,estatal,bissexual,desleal,fiscal,formal,pessoal,liberal,postal,virtual,visual,pontual,sideral,sucursal'],
          ['alismo', '4', '', '*'],
          ['ivismo', '4', '', '*'],
          ['ismo', '3', '', 'cinismo']
        ]
      end

      def verb_suffix_reduction
        format_rules [
          ['aríamo', '2', '', '*'],
          ['ássemo', '2', '', '*'],
          ['eríamo', '2', '', '*'],
          ['êssemo', '2', '', '*'],
          ['iríamo', '3', '', '*'],
          ['íssemo', '3', '', '*'],
          ['áramo', '2', '', '*'],
          ['árei', '2', '', '*'],
          ['aremo', '2', '', '*'],
          ['ariam', '2', '', '*'],
          ['aríei', '2', '', '*'],
          ['ássei', '2', '', '*'],
          ['assem', '2', '', '*'],
          ['ávamo', '2', '', '*'],
          ['êramo', '3', '', '*'],
          ['eremo', '3', '', '*'],
          ['eriam', '3', '', '*'],
          ['eríei', '3', '', '*'],
          ['êssei', '3', '', '*'],
          ['essem', '3', '', '*'],
          ['íramo', '3', '', '*'],
          ['iremo', '3', '', '*'],
          ['iriam', '3', '', '*'],
          ['iríei', '3', '', '*'],
          ['íssei', '3', '', '*'],
          ['issem', '3', '', '*'],
          ['ando', '2', '', '*'],
          ['endo', '3', '', '*'],
          ['indo', '3', '', '*'],
          ['ondo', '3', '', '*'],
          ['aram', '2', '', '*'],
          ['arão', '2', '', '*'],
          ['arde', '2', '', '*'],
          ['arei', '2', '', '*'],
          ['arem', '2', '', '*'],
          ['aria', '2', '', '*'],
          ['armo', '2', '', '*'],
          ['asse', '2', '', '*'],
          ['aste', '2', '', '*'],
          ['avam', '2', '', 'agravam'],
          ['ávei', '2', '', '*'],
          ['eram', '3', '', '*'],
          ['erão', '3', '', '*'],
          ['erde', '3', '', '*'],
          ['erei', '3', '', '*'],
          ['êrei', '3', '', '*'],
          ['erem', '3', '', '*'],
          ['eria', '3', '', '*'],
          ['ermo', '3', '', '*'],
          ['esse', '3', '', '*'],
          ['este', '3', '', 'faroeste,agreste'],
          ['íamo', '3', '', '*'],
          ['iram', '3', '', '*'],
          ['íram', '3', '', '*'],
          ['irão', '2', '', '*'],
          ['irde', '2', '', '*'],
          ['irei', '3', '', 'admirei'],
          ['irem', '3', '', 'adquirem'],
          ['iria', '3', '', '*'],
          ['irmo', '3', '', '*'],
          ['isse', '3', '', '*'],
          ['iste', '4', '', '*'],
          ['iava', '4', '', 'ampliava'],
          ['amo', '2', '', '*'],
          ['iona', '3', '', '*'],
          ['ara', '2', '', 'arara,prepara'],
          ['ará', '2', '', 'alvará'],
          ['are', '2', '', 'prepare'],
          ['ava', '2', '', 'agrava'],
          ['emo', '2', '', '*'],
          ['era', '3', '', 'acelera,espera'],
          ['erá', '3', '', '*'],
          ['ere', '3', '', 'espere'],
          ['iam', '3', '', 'enfiam,ampliam,elogiam,ensaiam'],
          ['íei', '3', '', '*'],
          ['imo', '3', '', 'reprimo,intimo,íntimo,nimo,queimo,ximo'],
          ['ira', '3', '', 'fronteira,sátira'],
          ['ído', '3', '', 'irá'],
          ['tizar', '4', '', 'alfabetizar'],
          ['izar', '5', '', 'organizar'],
          ['itar', '5', '', 'acreditar,explicitar,estreitar'],
          ['ire', '3', '', 'adquire'],
          ['omo', '3', '', '*'],
          ['ai', '2', '', '*'],
          ['am', '2', '', '*'],
          ['ear', '4', '', 'alardear,nuclear'],
          ['ar', '2', '', 'azar,bazaar,patamar'],
          ['uei', '3', '', '*'],
          ['uía', '5', 'u', '*'],
          ['ei', '3', '', '*'],
          ['guem', '3', 'g', '*'],
          ['em', '2', '', 'alem,virgem'],
          ['er', '2', '', 'éter,pier'],
          ['eu', '3', '', 'chapeu'],
          ['ia', '3', '', 'estória,fatia,acia,praia,elogia,mania,lábia,aprecia,polícia,arredia,cheia,ásia'],
          ['ir', '3', '', 'freir'],
          ['iu', '3', '', '*'],
          ['eou', '5', '', '*'],
          ['ou', '3', '', '*'],
          ['i', '3', '', '*']
        ]
      end

      def vowel_removal
        format_rules [
          ['bil', '2', 'vel', '*'],
          ['gue', '2', 'g', 'gangue,jegue'],
          ['á', '3', '', '*'],
          ['ê', '3', '', 'bebê'],
          ['a', '3', '', 'ásia'],
          ['e', '3', '', '*'],
          ['o', '3', '', 'ão']
        ]
      end
    end
  end
end
