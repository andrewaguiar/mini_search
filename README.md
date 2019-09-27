# MiniSearch

A simple and naive mini search engine in memory using TF IDF (PoC)

Minisearch implements BM25 algorithm

## BM25

![BM25 Formula](formula1.svg)

![IDF Formula](formula2.svg)

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
