# MiniSearch

A simple and naive mini search engine in memory using BM25 algorithm.

MiniSearch implements a inverted index (basically a hashmap where terms are keys and values are documents that contains that key.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_search'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mini_search

## Inverse Index

MiniSearch implements a inverted index (basically a hashmap where terms are keys and values are documents that contains that key.

Lets take two small documents as examples:

```
doc1 = 'The domestic dog is a member of the genus Canis, which forms part of the wolf-like canids'
doc2 = 'The cat is a small carnivorous mammal. It is the only domesticated species in the family Felidae and often referred to as the domestic cat.
```

To create an inverse index we start with an empty hashmap:

```
ii = {}
```

Now for a given document we transform its text in tokens (words):

```
doc1 = ["The", "domestic", "dog", "is", "a", "member", "of", "the", "genus", "Canis,", "which", "forms", "part", "of", "the", "wolf-like", "canids"]
doc2 = ["The", "cat", "is", "a", "small", "carnivorous", "mammal.", "It", "is", "the", "only", "domesticated", "species", "in", "the", "family", "Felidae", "and", "often", "referred", "to", "as", "the", "domestic", "cat."]
```

We take each term and create use it as a key in are hashmap `ii` and the value will be a list with all documents containing that term.

```
def index(doc_id, doc, ii)
  # 1 - tokenizer
  tokens = doc.split(' ')

  tokens.each { |token| ii[token] ||= []; ii[token] << doc_id }
end

ii = {}

index(:doc1, doc1, ii)
index(:doc2, doc2, ii)

puts ii

# {
#   'The'          => [:doc1, :doc2],
#   'domestic'     => [:doc1, :doc2],
#   'dog'          => [:doc1],
#   'is'           => [:doc1, :doc2],
#   'a'            => [:doc1, :doc2],
#   'member'       => [:doc1],
#   'of'           => [:doc1, :doc1],
#   'the'          => [:doc1, :doc2],
#   'genus'        => [:doc1],
#   'Canis,'       => [:doc1],
#   'which'        => [:doc1],
#   'forms'        => [:doc1],
#   'part'         => [:doc1],
#   'wolf-like'    => [:doc1],
#   'canids'       => [:doc1],
#   'cat'          => [:doc2],
#   'small'        => [:doc2],
#   'carnivorous'  => [:doc2],
#   'mammal.'      => [:doc2],
#   'It'           => [:doc2],
#   'only'         => [:doc2],
#   'domesticated' => [:doc2],
#   'species'      => [:doc2],
#   'in'           => [:doc2],
#   'family'       => [:doc2],
#   'Felidae'      => [:doc2],
#   'and'          => [:doc2],
#   'often'        => [:doc2],
#   'referred'     => [:doc2],
#   'to'           => [:doc2],
#   'as'           => [:doc2],
#   'cat.'         => [:doc2]
# }
```

Now it is ease to perform any search, if we want to get all documents about `cat` we could simply take the term cat and see the list o documents
in it `'cat' => [:doc2]`, if we want to search for 2 or more terms we can do the same `small cat` = `'cat' => [:doc2] and 'small' => [:doc2]`.

Clearly we can improve our index performing some transformations in the tokens before indexing them. For instance we can see we have `cat` and `cat.`
tokens, we have `The` and `the`. lets clean the data before indexing.

Lets change our define an index pipeline that will be called everytime a document is indexed

```
def index(doc_id, doc, ii)
  # 1 - tokenizer
  tokens = doc.split(' ')

  # 2 - downcase all tokens
  tokens = tokens.map(&:downcase)

  # 3 - remove punctuation
  tokens = tokens.map { |token| token.tr(',.!;:', '') }

  tokens.each { |token| ii[token] ||= []; ii[token] << doc_id }

  # ... index
end
```

With this changes our index would be:

```
{
  'the' => [:doc1, :doc2],
  'domestic' => [:doc1, :doc2],
  'dog' => [:doc1],
  'is' => [:doc1, :doc2],
  'a' => [:doc1, :doc2],
  'member' => [:doc1],
  'of' => [:doc1],
  'genus' => [:doc1],
  'canis' => [:doc1],
  'which' => [:doc1],
  'forms' => [:doc1],
  'part' => [:doc1],
  'wolf-like' => [:doc1],
  'canids' => [:doc1],
  'cat' => [:doc2],
  'small' => [:doc2],
  'carnivorous' => [:doc2],
  'mammal' => [:doc2],
  'it' => [:doc2],
  'only' => [:doc2],
  'domesticated' => [:doc2],
  'species' => [:doc2],
  'in' => [:doc2],
  'family' => [:doc2],
  'felidae' => [:doc2],
  'and' => [:doc2],
  'often' => [:doc2],
  'referred' => [:doc2],
  'to' => [:doc2],
  'as' => [:doc2]
}
```

Pretty better


## BM25 (from wikipedia)

BM25 is a bag-of-words retrieval function that ranks a set of documents based on the query terms appearing in each document, regardless 
of their proximity within the document. It is a family of scoring functions with slightly different components and parameters.
One of the most prominent instantiations of the function is as follows.

Given a query Q, containing keywords `q1....qn` the BM25 score of a document `D` is:

![BM25 Formula](formula1.svg)

where `f(qi, D)` is qi's term frequency (tf) in the document `D`, `|D|` is the length of the document `D` in words, and avgdl is the 
average document length in the text collection from which documents are drawn. `k1` and `b` are free parameters, usually chosen, in absence of
an advanced optimization, as `k1 in |1.2,2.0|` and `b = 0.75`. `IDF(qi)` is the IDF (inverse document frequency) weight of the query term
`qi`. It is usually computed as:

![IDF Formula](formula2.svg)

where `N` is the total number of documents in the collection, and `n(q)` is the number of documents containing `qi`.

There are several interpretations for IDF and slight variations on its formula. In the original BM25 derivation,
the IDF component is derived from the Binary Independence Model.

The above formula for IDF has drawbacks for terms appearing in more than half of the corpus documents. These terms' IDF is negative,
so for any two almost-identical documents, one which contains the term may be ranked lower than one which does not. This is often an
undesirable behavior, so many applications adjust the IDF formula in various ways:

Each summand can be given a floor of 0, to trim out common terms;
The IDF function can be given a floor of a constant `e`, to avoid common terms being ignored at all;
The IDF function can be replaced with a similarly shaped one which is non-negative, or strictly positive to avoid terms being ignored at all.

## Usage

First we create an inverted Index

```ruby
  idx = MiniSearch.new_index

  # Then we index some documents (a document is a simple Hash with :id and :indexed_field in it)

  idx.index(id: 1, indexed_field: 'red duck')
  idx.index(id: 2, indexed_field: 'yellow big dog')
  idx.index(id: 3, indexed_field: 'small cat')
  idx.index(id: 4, indexed_field: 'red monkey noisy')
  idx.index(id: 5, indexed_field: 'small horse')
  idx.index(id: 6, indexed_field: 'purple turtle')
  idx.index(id: 7, indexed_field: 'tiny red spider')
  idx.index(id: 8, indexed_field: 'big blue whale')
  idx.index(id: 9, indexed_field: 'huge elephant')
  idx.index(id: 10, indexed_field: 'red big cat')

  # Then we can search for our documents

  result = idx.search('RED  cat ')

  # The result will be something like:

  puts result

  # {
  #   documents: [
  #     { document: { id: 10, indexed_field: 'red big cat' }, score: 2.726770362793935 },
  #     { document: { id: 3, indexed_field: 'small cat' }, score: 1.860138656065616 },
  #     { document: { id: 4, indexed_field: 'red monkey noisy' }, score: 0.630035123281377 },
  #     { document: { id: 7, indexed_field: 'tiny red spider' }, score: 0.630035123281377 },
  #     { document: { id: 1, indexed_field: 'red duck' }, score: 0.5589416657904823 }
  #   ],
  #   idfs: {
  #     'cat' => 1.2237754316221157,
  #     'red' => 0.36772478012531734
  #   },
  #   processed_terms: ['red', 'cat']
  # }
```

We can see results are sorted by score, notice that the document we index can have any other 
fields like name, price and etc. But only `:id` and `:indexed_field` are required

## Pipelines




## Language support (stop words, stemmers)

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mini_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MiniSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mini_search/blob/master/CODE_OF_CONDUCT.md).
