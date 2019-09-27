RSpec.describe MiniSearch::Stemmer::Portuguese do
  subject { MiniSearch::Stemmer::Portuguese.new }

  it 'extracts steam' do
    expect(subject.stem('gato')).to eq('gat')
    expect(subject.stem('gata')).to eq('gat')
    expect(subject.stem('gatos')).to eq('gat')
    expect(subject.stem('gatas')).to eq('gat')
    expect(subject.stem('gatinho')).to eq('gat')
    expect(subject.stem('gatinha')).to eq('gat')
    expect(subject.stem('gatinhas')).to eq('gat')
    expect(subject.stem('gatinhos')).to eq('gat')
    expect(subject.stem('gatão')).to eq('gat')
    expect(subject.stem('gatona')).to eq('gat')
  end

  context 'when using portuguese stemmer' do
    subject { MiniSearch.new_localized_index(:pt) }

    before do
      subject.index(id: 1, indexed_field: 'cachorro')
      subject.index(id: 2, indexed_field: 'motor')
      subject.index(id: 3, indexed_field: 'gatos')
      subject.index(id: 4, indexed_field: 'gatinho')
      subject.index(id: 5, indexed_field: 'aneis')
    end

    it 'searches inhos ending word' do
      expect(subject.search('cachorrinhos')).to eq(
        documents: [
          { document: { id: 1, indexed_field: 'cachorro' }, score: 1.9775021196025977 }
        ],
        idfs: {
          'cachorr' => 1.0986122886681098
        },
        processed_terms: ['cachorr', 'cachorrinhos']
      )
    end

    it 'searches res ending word' do
      expect(subject.search('motores')).to eq(
        documents: [
          { document: { id: 2, indexed_field: 'motor' }, score: 1.9775021196025977 }
        ],
        idfs: {
          'motor' => 1.0986122886681098
        },
        processed_terms: ['motor', 'motores']
      )
    end

    it 'searches eis ending word' do
      expect(subject.search('anel')).to eq(
        documents: [
          { document: { id: 5, indexed_field: 'aneis' }, score: 1.9775021196025977 }
        ],
        idfs: {
          'anel' => 1.0986122886681098
        },
        processed_terms: ['anel']
      )
    end

    it 'searches by stemmed term but keeps relevance for original term' do
      expect(subject.search('gatinho')).to eq(
        documents: [
          { document: { id: 4, indexed_field: 'gatinho' }, score: 2.583152145520781 },
          { document: { id: 3, indexed_field: 'gatos' }, score: 0.6056500259181832 }
        ],
        idfs: {
          'gat' => 0.3364722366212129,
          'gatinho' => 1.0986122886681098
        },
        processed_terms: ['gat', 'gatinho'],
      )
    end
  end
end
