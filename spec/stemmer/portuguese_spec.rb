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
          { document: { id: 1, indexed_field: 'cachorro' }, score: 0.8047189562170501 }
        ],
        idfs: {
          'cachorr' => 1.6094379124341003
        },
        processed_terms: ['cachorr', 'cachorrinhos']
      )
    end

    it 'searches res ending word' do
      expect(subject.search('motores')).to eq(
        documents: [
          { document: { id: 2, indexed_field: 'motor' }, score: 1.6094379124341003 }
        ],
        idfs: {
          'motor' => 1.6094379124341003
        },
        processed_terms: ['motor', 'motores']
      )
    end

    it 'searches eis ending word' do
      expect(subject.search('anel')).to eq(
        documents: [
          { document: { id: 5, indexed_field: 'aneis' }, score: 0.8047189562170501 }
        ],
        idfs: {
          'anel' => 1.6094379124341003
        },
        processed_terms: ['anel']
      )
    end

    it 'searches by stemmed term but keeps relevance for original term' do
      expect(subject.search('gatinho')).to eq(
        documents: [
          { document: { id: 4, indexed_field: 'gatinho' }, score: 1.2628643221541278 },
          { document: { id: 3, indexed_field: 'gatos' }, score: 0.45814536593707755 }
        ],
        idfs: {
          'gat' => 0.9162907318741551,
          'gatinho' => 1.6094379124341003
        },
        processed_terms: ['gat', 'gatinho'],
      )
    end
  end
end
