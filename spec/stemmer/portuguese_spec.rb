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

  it 'indexes documents and searches them' do
    idx = MiniSearch.new_index(stemmer: ::MiniSearch::Stemmer::Portuguese.new)

    idx.index(id: 1, indexed_field: 'cachorro')
    idx.index(id: 2, indexed_field: 'motor')
    idx.index(id: 3, indexed_field: 'aneis')

    expect(idx.search('cachorrinhos')).to eq([
      { document: { id: 1, indexed_field: 'cachorro' }, score: 0.5493061443340549 }
    ])

    expect(idx.search('motores')).to eq([
      { document: { id: 2, indexed_field: 'motor' }, score: 1.0986122886681098 }
    ])

    expect(idx.search('anel')).to eq([
      { document: { id: 3, indexed_field: 'aneis' }, score: 0.5493061443340549 }
    ])
  end
end
