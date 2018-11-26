# Atomically

[![Gem Version](https://img.shields.io/gem/v/atomically.svg?style=flat)](https://rubygems.org/gems/atomically)
[![Build Status](https://api.travis-ci.com/khiav223577/atomically.svg?branch=master)
[![RubyGems](http://img.shields.io/gem/dt/atomically.svg?style=flat)](https://rubygems.org/gems/atomically)
[![Code Climate](https://codeclimate.com/github/khiav223577/atomically/badges/gpa.svg)](https://codeclimate.com/github/khiav223577/atomically)
[![Test Coverage](https://codeclimate.com/github/khiav223577/atomically/badges/coverage.svg)](https://codeclimate.com/github/khiav223577/atomically/coverage)

`atomically` is a Ruby Gem for you to write atomic query with ease.

Supports Rails 3.2, 4.2, 5.0, 5.1, 5.2.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atomically'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install atomically

## Usage

### create_or_plus

Import an array of records. When key is duplicate, plus the old value with new value.
It is useful to add `items` to `user` when `user_items` may not exist.

First two args (columns, values) are the same with the [import](https://github.com/zdennis/activerecord-import#columns-and-arrays) method.

Example:
```rb
user = User.find(2)
item1 = Item.find(1)
item2 = Item.find(2)
```

```rb
columns = [:user_id, :item_id, :quantity]
values = [[user.id, item1.id, 3], [user.id, item2.id, 2]]
on_duplicate_update_columns = [:quantity]

UserItem.atomically.create_or_plus(columns, values, on_duplicate_update_columns)
```

#### before
![before](https://user-images.githubusercontent.com/4011729/48998921-ff430600-f18f-11e8-8eeb-e8a71bbf5802.png)

#### after
![image](https://user-images.githubusercontent.com/4011729/48999092-8d1ef100-f190-11e8-8372-86e2e99cbe08.png)


### pay_all
Reduce the quantity of items and return how many rows and updated if all of them is enough.
Do nothing and return zero if any of them is not enough.

Example:
```rb
user.user_items.atomically.pay_all({ item1.id => 4, item2.id => 3 }, [:quantity], primary_key: :item_id)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test DB=mysql` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khiav223577/atomically. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

