RSpec.describe MiniSearch::NgramTokenizer do

    let(:window) { nil }

    subject { MiniSearch::NgramTokenizer.new(window) }

    it 'defaults to bigrams if n is not provided' do
        expect(subject.execute('Hello')).to eq(
            [
                'He',
                'el',
                'll',
                'lo'
            ]
        )
    end

    context 'bigrams' do
        let(:window) { 2 }

        it 'produces bigrams if n is 2' do
            expect(subject.execute('Hello')).to eq(
                [
                    'He',
                    'el',
                    'll',
                    'lo'
                ]
            )
            expect(subject.execute('Hello World!')).to eq(
                [
                    'He',
                    'el',
                    'll',
                    'lo',
                    'o ',
                    ' W',
                    'Wo',
                    'or',
                    'rl',
                    'ld',
                    'd!'
                ]
            )
        end
    end


    context 'trigrams' do
        let(:window) { 3 }

        it 'produces bigrams if n is 3' do
            expect(subject.execute('Hello')).to eq(
                [
                    'Hel',
                    'ell',
                    'llo'
                ]
            )
            expect(subject.execute('Hello World!')).to eq(
                [
                    'Hel',
                    'ell',
                    'llo',
                    'lo ',
                    'o W',
                    ' Wo',
                    'Wor',
                    'orl',
                    'rld',
                    'ld!'
                ]
            )
        end
    end

end
