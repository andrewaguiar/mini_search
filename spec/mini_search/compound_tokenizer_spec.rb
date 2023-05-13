RSpec.describe MiniSearch::CompoundTokenizer do
  let(:n) { nil }

  let(:standard_whitespace_tokenizer) { MiniSearch::StandardWhitespaceTokenizer.new }
  let(:ngram_tokenizer) { MiniSearch::NgramTokenizer.new(2) }

  subject do
    MiniSearch::CompoundTokenizer.new([ngram_tokenizer, standard_whitespace_tokenizer])
  end

  it 'defaults to bigrams if n is not provided' do
    expect(subject.execute('Hello')).to eq(
      ['He', 'el', 'll', 'lo', 'Hello']
    )
  end
end
