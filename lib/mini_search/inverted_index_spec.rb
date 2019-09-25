module MiniSearch
  RSpec.describe InvertedIndex do
    subject { InvertedIndex.new }

    it "indexes documents and searches them" do
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
  end
end
