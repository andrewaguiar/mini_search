RSpec.describe MiniSearch::InvertedIndex do
  let(:stop_words) { [] }
  let(:synonyms_map) { {} }

  subject { MiniSearch.new_index(stop_words: stop_words, synonyms_map: synonyms_map) }

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
        { document: { id: 10, indexed_field: 'red big cat' }, score: 0.8419095481027516 },

        # 3 - matches cat so it is the second as cat has a bigger IDF (it is more uncommon)
        { document: { id: 3, indexed_field: 'small cat' }, score: 0.8047189562170501 },

        # 1 - matches red but has only 2 terms, so the red here has a bigger weight
        { document: { id: 1, indexed_field: 'red duck' }, score: 0.45814536593707755 },

        # 4, 7 - both match red as well, but they have 3 terms, so red here has a lower frequency (tf)
        # comparing with 1
        { document: { id: 4, indexed_field: 'red monkey noisy' }, score: 0.3054302439580517 },
        { document: { id: 7, indexed_field: 'tiny red spider' }, score: 0.3054302439580517 }
      ],
      idfs: {
        'cat' => 1.6094379124341003,
        'red' => 0.9162907318741551
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
        { document: { id: 10, indexed_field: 'red big cat' }, score: 0.8419095481027516 }
      ],
      idfs: {
        'cat' => 1.6094379124341003,
        'red' => 0.9162907318741551
      },
      processed_terms: ['red', 'cat']
    )
  end

  it 'preserves extra fields in documents' do
    subject.index(id: 1, indexed_field: 'red duck', image: 'https://live.staticflickr.com/3229/2473722665_7720218d41_b.jpg')

    expect(subject.search('red cat')).to eq(
      documents: [
        { document: { id: 1, indexed_field: 'red duck', image: 'https://live.staticflickr.com/3229/2473722665_7720218d41_b.jpg' }, score: 0.0 }
      ],
      idfs: {
        'red' => 0.0
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
          { document: { id: 1, indexed_field: 'the red duck' }, score: 0.6931471805599453 }
        ],
        idfs: {
          'duck' => 1.3862943611198906
        },
        processed_terms: ['duck']
      )

      expect(subject.search('an ladybug')).to eq(
        documents: [
          { document: { id: 4, indexed_field: 'an strong ladybug' }, score: 0.6931471805599453 },
        ],
        idfs: {
          'ladybug' => 1.3862943611198906
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
          { document: { id: 1, indexed_field: 'my best friend dog' }, score: 0.0 }
        ],
        idfs: {
          'dog' => 0.0
        },
        processed_terms: ['doge', 'dog']
      )

      expect(subject.search('hound')).to eq(
        documents: [
          { document: { id: 1, indexed_field: 'my best friend dog' }, score: 0.0 }
        ],
        idfs: {
          'dog' => 0.0
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
end
