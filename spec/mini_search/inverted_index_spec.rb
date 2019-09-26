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

    expect(subject.search('red cat')).to eq([
      # 10 - matches both red and cat so it is the first
      { document: { id: 10, indexed_field: 'red big cat' }, score: 0.4666666666666667 },

      # 3 - matches cat so it is the second as cat has a bigger IDF (it is more uncommon)
      { document: { id: 3, indexed_field: 'small cat' }, score: 0.4 },

      # 1 - matches red but has only 2 terms, so the red here has a bigger weight
      { document: { id: 1, indexed_field: 'red duck' }, score: 0.3 },

      # 4, 7 - both match red as well, but they have 3 terms, so red here has a lower frequency (tf)
      # comparing with 1
      { document: { id: 4, indexed_field: 'red monkey noisy' }, score: 0.19999999999999998 },
      { document: { id: 7, indexed_field: 'tiny red spider' }, score: 0.19999999999999998 }
    ])
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

    expect(subject.search('red cat', operator: 'and')).to eq([
      { document: { id: 10, indexed_field: 'red big cat' }, score: 0.4666666666666667 }
    ])
  end

  it 'preserves extra fields in documents' do
    subject.index(id: 1, indexed_field: 'red duck', image: 'https://live.staticflickr.com/3229/2473722665_7720218d41_b.jpg')

    expect(subject.search('red cat')).to eq([
      {
        document: {
          id: 1,
          indexed_field: 'red duck',
          image: 'https://live.staticflickr.com/3229/2473722665_7720218d41_b.jpg'
        },
        score: 0.0
      }
    ])
  end

  context 'using stop words' do
    let(:stop_words) { ['the', 'an'] }

    it 'uses stop words to remove common words' do
      subject.index(id: 1, indexed_field: 'the red duck')
      subject.index(id: 2, indexed_field: 'an yellow big dog')
      subject.index(id: 3, indexed_field: 'the golden horse')
      subject.index(id: 4, indexed_field: 'an strong ladybug')

      expect(subject.search('the duck')).to eq([
        { document: { id: 1, indexed_field: 'the red duck' }, score: 0.375 },
      ])

      expect(subject.search('an ladybug')).to eq([
        { document: { id: 4, indexed_field: 'an strong ladybug' }, score: 0.375 },
      ])
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

      expect(subject.search('doge')).to eq([
        { document: { id: 1, indexed_field: 'my best friend dog' }, score: 0.0 }
      ])

      expect(subject.search('hound')).to eq([
        { document: { id: 1, indexed_field: 'my best friend dog' }, score: 0.0 }
      ])
    end
  end

  it 'returns an empty array when search does not match' do
    subject.index(id: 10, indexed_field: 'red big cat')

    expect(subject.search('hippo')).to eq([])
  end

  it 'returns an empty array when index empty' do
    expect(subject.search('red cat')).to eq([])
  end
end
