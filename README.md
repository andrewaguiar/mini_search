# MiniSearch

A simple and naive mini search engine in memory using TF IDF (PoC)

Minisearch implements BM25 algorithm

## BM25

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

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mini_search'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mini_search

## Usage

First we create an inverted Index

```ruby
  idx = MiniSearch.new_index
```

Then we index some documents (a document is a simple Hash with :id and :indexed_field in it)

```ruby
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
```

Then we can search for our documents

```ruby
  result = idx.search('RED  cat ')
```

The result will be something like:

```
[
  { document: { id: 10, indexed_field: 'red big cat' }, score: 0.4666666666666667 },
  { document: { id: 3, indexed_field: 'small cat' }, score: 0.4 },
  { document: { id: 1, indexed_field: 'red duck' }, score: 0.3 },
  { document: { id: 4, indexed_field: 'red monkey noisy' }, score: 0.19999999999999998 },
  { document: { id: 7, indexed_field: 'tiny red spider' }, score: 0.19999999999999998 }
]
```

We can see results are sorted by score, notice that the document we index can have any other 
fields like name, price and etc. But only `:id` and `:indexed_field` are required

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mini_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MiniSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mini_search/blob/master/CODE_OF_CONDUCT.md).
