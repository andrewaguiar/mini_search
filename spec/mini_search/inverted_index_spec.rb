RSpec.describe MiniSearch::InvertedIndex do
  let(:stop_words) { [] }
  let(:synonyms_map) { {} }
  let(:ngrams) { nil }

  subject { MiniSearch.new_index(stop_words: stop_words, synonyms_map: synonyms_map, ngrams: ngrams) }

  it 'indexes documents and searches them' do
    subject.index(id: 1, indexed_field: 'red duck')
    subject.index(id: 2, indexed_field: 'yellow big dog')
    subject.index(id: 3, indexed_field: 'small cat')
    subject.index(id: 4, indexed_field: 'red monkey noisy')
    subject.index(id: 5, indexed_field: 'small horse')
    subject.index(id: 6, indexed_field: 'purple turtle')
    subject.index(id: 7, indexed_field: 'tiny red spider')
    subject.index(id: 8, indexed_field: 'big blue whale')
    subject.index(id: 9, indexed_field: 'huge elephant')
    subject.index(id: 10, indexed_field: 'red big cat')

    expect(subject.search('red cat')).to eq(
      documents: [
        # 10 - matches both red and cat so it is the first
        { document: { id: 10, indexed_field: 'red big cat' }, score: 2.726770362793935 },

        # 3 - matches cat so it is the second as cat has a bigger IDF (it is more uncommon)
        { document: { id: 3, indexed_field: 'small cat' }, score: 1.860138656065616 },

        { document: { id: 4, indexed_field: 'red monkey noisy' }, score: 0.630035123281377 },
        { document: { id: 7, indexed_field: 'tiny red spider' }, score: 0.630035123281377 },
        { document: { id: 1, indexed_field: 'red duck' }, score: 0.5589416657904823 }
      ],
      idfs: {
        'cat' => 1.2237754316221157,
        'red' => 0.36772478012531734
      },
      processed_terms: ['red', 'cat']
    )
  end

  it 'indexes documents and searches them using AND operator' do
    subject.index(id: 1, indexed_field: 'red duck')
    subject.index(id: 2, indexed_field: 'yellow big dog')
    subject.index(id: 3, indexed_field: 'small cat')
    subject.index(id: 4, indexed_field: 'red monkey noisy')
    subject.index(id: 5, indexed_field: 'small horse')
    subject.index(id: 6, indexed_field: 'purple turtle')
    subject.index(id: 7, indexed_field: 'tiny red spider')
    subject.index(id: 8, indexed_field: 'big blue whale')
    subject.index(id: 9, indexed_field: 'huge elephant')
    subject.index(id: 10, indexed_field: 'red big cat')

    expect(subject.search('red cat', operator: 'and')).to eq(
      documents: [
        { document: { id: 10, indexed_field: 'red big cat' }, score: 2.726770362793935 }
      ],
      idfs: {
        'cat' => 1.2237754316221157,
        'red' => 0.36772478012531734
      },
      processed_terms: ['red', 'cat']
    )
  end

  it 'preserves extra fields in documents' do
    subject.index(id: 1, indexed_field: 'red duck', image: 'https://live.staticflickr.com/3229/2473722665_7720218d41_b.jpg')

    expect(subject.search('red cat')).to eq(
      documents: [
        { document: { id: 1, indexed_field: 'red duck', image: 'https://live.staticflickr.com/3229/2473722665_7720218d41_b.jpg' }, score: -1.8676408907357867 }
      ],
      idfs: {
        'red' => -1.0986122886681098
      },
      processed_terms: ['red', 'cat'],
    )
  end

  context 'using stop words' do
    let(:stop_words) { ['the', 'an'] }

    it 'uses stop words to remove common words' do
      subject.index(id: 1, indexed_field: 'the red duck')
      subject.index(id: 2, indexed_field: 'an yellow big dog')
      subject.index(id: 3, indexed_field: 'the golden horse')
      subject.index(id: 4, indexed_field: 'an strong ladybug')

      expect(subject.search('the duck')).to eq(
        documents: [
          { document: { id: 1, indexed_field: 'the red duck' }, score: 1.3556765766195258 }
        ],
        idfs: {
          'duck' => 0.8472978603872037
        },
        processed_terms: ['duck']
      )

      expect(subject.search('an ladybug')).to eq(
        documents: [
          { document: { id: 4, indexed_field: 'an strong ladybug' }, score: 1.3556765766195258 },
        ],
        idfs: {
          'ladybug' => 0.8472978603872037
        },
        processed_terms: ['ladybug']
      )
    end
  end

  context 'using synonyms' do
    let(:synonyms_map) do
      {
        'dog' => ['doge', 'hound']
      }
    end

    it 'uses stop words to remove common words' do
      subject.index(id: 1, indexed_field: 'my best friend dog')

      expect(subject.search('doge')).to eq(
        documents: [
          { document: { id: 1, indexed_field: 'my best friend dog' }, score: -1.5929878185687592 }
        ],
        idfs: {
          'dog' => -1.0986122886681098
        },
        processed_terms: ['doge', 'dog']
      )

      expect(subject.search('hound')).to eq(
        documents: [
          { document: { id: 1, indexed_field: 'my best friend dog' }, score: -1.5929878185687592 }
        ],
        idfs: {
          'dog' => -1.0986122886681098
        },
        processed_terms: ['hound', 'dog']
      )
    end
  end

  it 'returns an empty array when search does not match' do
    subject.index(id: 10, indexed_field: 'red big cat')

    expect(subject.search('hippo')).to eq(
      documents: [],
      idfs: {},
      processed_terms: ['hippo']
    )
  end

  it 'returns an empty array when index empty' do
    expect(subject.search('red cat')).to eq(
      documents: [],
      idfs: {},
      processed_terms: ['red', 'cat']
    )
  end

  context 'using ngrams' do
    let(:ngrams) { 2 }

    it 'uses ngram tokenizer if ngrams is not nil' do
      subject.index(id: 1, indexed_field: 'red duck')
      subject.index(id: 2, indexed_field: 'yellow big dog')
      subject.index(id: 3, indexed_field: 'small cat')
      subject.index(id: 4, indexed_field: 'red monkey noisy')
      subject.index(id: 5, indexed_field: 'small horse')
      subject.index(id: 6, indexed_field: 'purple turtle')
      subject.index(id: 7, indexed_field: 'tiny red spider')
      subject.index(id: 8, indexed_field: 'big blue whale')
      subject.index(id: 9, indexed_field: 'huge elephant')
      subject.index(id: 10, indexed_field: 'red big cat')

      expect(subject.search('red cat')).to eq(
        documents: [
          # 10 - matches both red and cat so it is the first
          { document: { id: 10, indexed_field: 'red big cat' }, score: 5.2417439118759885 },

          # 3 - matches cat so it is the second as cat has a bigger IDF (it is more uncommon)
          { document: { id: 3, indexed_field: 'small cat' }, score: 3.87904607207589 },

          { document: { id: 4, indexed_field: 'red monkey noisy' }, score: 1.1405919495816859 },
          { document: { id: 7, indexed_field: 'tiny red spider' }, score: 1.0860322829565763 },
          { document: { id: 1, indexed_field: 'red duck' }, score: 0.7321317426855942 },

          # Pulls in an extra document because of ngramming ("d" in dog)
          { document: { id: 2, indexed_field: 'yellow big dog' }, score: 0.0 },
        ],
        idfs: {
          'at' => 1.2237754316221157,
          'c' => 1.2237754316221157,
          'ca' => 1.2237754316221157,
          'd' => 0.0,
          'ed' => 0.36772478012531734,
          're' => 0.36772478012531734
        },
        processed_terms: ['re', 'ed', 'd', 'c', 'ca', 'at']
      )
    end

  end

end
