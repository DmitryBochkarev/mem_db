# MemDb

Embedded database with support of composite indices and complex document matching.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mem_db'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mem_db

## Usage

```ruby
# Define how fields will be matched
fields = MemDB::Fields.new([
  MemDB::Field::Enum.new(:category),
  MemDB::Field::Enum.new(:"!category").query(:category).negative,

  MemDB::Field::Regexp.new(:text),
  MemDB::Field::Regexp.new(:"!text").query(:text).negative,

  MemDB::Field::Pattern.new(:breadcrumbs),
  MemDB::Field::Pattern.new(:"!breadcrumbs").query(:breadcrumbs).negative,
].map!(&:may_missing))

# Specify index

index = MemDB::Index.compose([
  MemDB::Index::Enum::Bucket.new(
    idx: MemDB::Idx::Itself.new(:category).default_any
  ).accept_any,
  MemDB::Index::PatternMatch::Bucket.new(
    idx: MemDB::Idx::Pattern.new(:breadcrumbs).default_any
  ).accept_any,
])

# Create database instance

db = MemDB.new(fields, index)

# Indexate

indexation = db.new_indexation

indexation.add(
  {
    category: "food",
    text: ".*fish.*",
    breadcrumbs: "*/retail/*"
  },
  :food_fish
)
indexation.add(
  {
    "!category": "food",
    text: ".*fish.*",
    breadcrumbs: "*/retail/*"
  },
  :not_food_fish
)

# Query

MemDB::Query.new({
  category: "toy",
  text: "animated fish",
  breadcrumbs: "/shops/retail/123"
}).using(database)
# => [:not_food_fish]

MemDB::Query.new({
  category: "food",
  text: "delicious fish",
  breadcrumbs: "/shops/retail/123"
}).using(database)
# => [:food_fish]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryBochkarev/mem_db.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

```

```
