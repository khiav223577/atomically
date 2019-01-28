# Atomically

[![Gem Version](https://img.shields.io/gem/v/atomically.svg?style=flat)](https://rubygems.org/gems/atomically)
[![Build Status](https://api.travis-ci.com/khiav223577/atomically.svg?branch=master)](https://travis-ci.com/khiav223577/atomically)
[![RubyGems](http://img.shields.io/gem/dt/atomically.svg?style=flat)](https://rubygems.org/gems/atomically)
[![Code Climate](https://codeclimate.com/github/khiav223577/atomically/badges/gpa.svg)](https://codeclimate.com/github/khiav223577/atomically)
[![Test Coverage](https://codeclimate.com/github/khiav223577/atomically/badges/coverage.svg)](https://codeclimate.com/github/khiav223577/atomically/coverage)

`atomically` is a Ruby Gem for you to write atomic query with ease.

Supports Rails 3.2, 4.2, 5.0, 5.1, 5.2.

## Table of contents

1. [Installation](#installation)
2. [Methods](#methods)
   - Relation Methods
     - [create_or_plus](#create_or_plus-columns-values-on_duplicate_update_columns)
     - [pay_all](#pay_all-hash-update_columns-primary_key-id)
     - [update_all](#update_all-expected_number-updates)
     - [update_all_and_get_ids](#update_all_and_get_ids-updates)
   - Model Methods
     - [update](#update-attrs-from-not_set)
     - [decrement_unsigned_counters](#decrement_unsigned_counters-counters)
3. [Development](#development)
4. [Contributing](#contributing)
5. [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atomically'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install atomically

## Methods

Note: ActiveRecord validations and callbacks will **NOT** be triggered when calling below methods.

### create_or_plus _(columns, values, on_duplicate_update_columns)_

Import an array of records. When key is duplicate, plus the old value with new value.
It is useful to add `items` to `user` when `user_items` may not exist.

#### Parameters

  - First two args (`columns`, `values`) are the same with the [import](https://github.com/zdennis/activerecord-import#columns-and-arrays) method.
  - `on_duplicate_update_columns` - The column that will be updated on duplicate.

#### Example

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

before

![before](https://user-images.githubusercontent.com/4011729/48998921-ff430600-f18f-11e8-8eeb-e8a71bbf5802.png)

after

![image](https://user-images.githubusercontent.com/4011729/48999092-8d1ef100-f190-11e8-8372-86e2e99cbe08.png)

#### SQL queries

```sql
INSERT INTO `user_items` (`user_id`,`item_id`,`quantity`,`created_at`,`updated_at`) VALUES
  (2,1,3,'2018-11-27 03:44:25','2018-11-27 03:44:25'),
  (2,2,2,'2018-11-27 03:44:25','2018-11-27 03:44:25')
ON DUPLICATE KEY UPDATE `quantity` = `quantity` + VALUES(`quantity`)
```

---
### pay_all _(hash, update_columns, primary_key: :id)_

Reduce the quantity of items and return how many rows and updated if all of them is enough.
Do nothing and return zero if any of them is not enough.

#### Parameters

  - `hash` - A hash contains the id of the models as keys and the amount to update the field by as values.
  - `update_columns` - The column that will be updated.
  - `primary_key` - Specify the column that `id`(the key of hash) refer to.

#### Example

```rb
user.user_items.atomically.pay_all({ item1.id => 4, item2.id => 3 }, [:quantity], primary_key: :item_id)
```

#### SQL queries

```sql
UPDATE `user_items` SET `quantity` = `quantity` + (@change :=
  CASE `item_id`
  WHEN 1 THEN -4
  WHEN 2 THEN -3
  END)
WHERE `user_items`.`user_id` = 1 AND (
  `user_items`.`item_id` = 1 AND (`quantity` >= 4) OR `user_items`.`item_id` = 2 AND (`quantity` >= 3)
) AND (
  (
    SELECT COUNT(*) FROM (
      SELECT `user_items`.* FROM `user_items`
      WHERE `user_items`.`user_id` = 1 AND (
        `user_items`.`item_id` = 1 AND (`quantity` >= 4) OR `user_items`.`item_id` = 2 AND (`quantity` >= 3)
      )
    ) subquery
  ) = 2
)
```

---
### update_all _(expected_number, updates)_

Behaves like [ActiveRecord::Relation#update_all](https://apidock.com/rails/ActiveRecord/Relation/update_all) but add an additional constrain that the number of affected rows equals to what you specify.

#### Parameters

  - `expected_number` - The number of rows that you expect to be updated.
  - `updates` - A string, array, or hash representing the SET part of an SQL statement.

#### Examples
```rb
User.where(id: [1, 2]).atomically.update_all(2, name: '')
# => 2

User.where(id: [1, 2, 3]).atomically.update_all(2, name: '')
# => 0
```

#### SQL queries

```sql
# User.where(id: [1, 2, 3]).atomically.update_all(2, name: '')
UPDATE `users` SET `users`.`name` = '' WHERE `users`.`id` IN (1, 2, 3) AND (
  (
    SELECT COUNT(*) FROM (
      SELECT `users`.* FROM `users` WHERE `users`.`id` IN (1, 2, 3)
    ) subquery
  ) = 2
)
```

---
### update_all_and_get_ids _(updates)_

Behaves like [ActiveRecord::Relation#update_all](https://apidock.com/rails/ActiveRecord/Relation/update_all), but return the ids array of updated records instead of the number of updated records.


#### Parameters

  - `updates` - A string, array, or hash representing the SET part of an SQL statement.

#### Example

```rb
User.where(account: ['moon', 'wolf']).atomically.update_all_and_get_ids('money = money + 1')
# => [254, 371]
```

#### SQL queries

```sql
BEGIN
  SET @ids := NULL
  UPDATE `users` SET money = money + 1 WHERE `users`.`account` IN ('moon', 'wolf') AND ((SELECT @ids := CONCAT_WS(',', `users`.`id`, @ids)))
  SELECT @ids FROM DUAL
COMMIT
```

---
### update _(attrs, from: :not_set)_

Updates the attributes of the model from the passed-in hash and saves the record. The difference between this method and [ActiveRecord#update](https://apidock.com/rails/ActiveRecord/Persistence/update) is that it will add extra WHERE conditions to prevent race condition.

#### Parameters

  - `attrs` - Same with the first parameter of [ActiveRecord#update](https://apidock.com/rails/ActiveRecord/Persistence/update)
  - `from` - The value before update. If not set, use the current attriutes of the model.

#### Example

```rb
class Arena < ApplicationRecord
  def atomically_close!
    atomically.update(closed_at: Time.now)
  end

  def close!
    update(closed_at: Time.now)
  end
end
```

#### SQL queries

```sql
# arena.atomically_close!
# (let arena.closed_at to be nil)
UPDATE `arenas` SET `arenas`.`closed_at` = '2018-11-27 03:44:25', `updated_at` = '2018-11-27 03:44:25'
WHERE `arenas`.`id` = 1752 AND `arenas`.`closed_at` IS NULL

# arena.close!
UPDATE `arenas` SET `arenas`.`closed_at` = '2018-11-27 03:44:25', `updated_at` = '2018-11-27 03:44:25'
WHERE `arenas`.`id` = 1752
```

---
### decrement_unsigned_counters _(counters)_

Decrement numeric fields via a direct SQL update, and make sure that it will not become negative.


#### Parameters

  - `counters` - A Hash containing the names of the fields to update as keys and the amount to update the field by as values.

#### Example

```rb
user.money
# => 100

user.atomically.decrement_unsigned_counters(money: 10)
# => true
user.reload.money
# => 90

user.atomically.decrement_unsigned_counters(money: 999)
# => false
user.reload.money
# => 90
```

#### SQL queries

```sql
# user.atomically.decrement_unsigned_counters(money: 140)
UPDATE `users` SET money = money - 10 WHERE `users`.`id` = 1 AND (money > 140)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test DB=mysql` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/khiav223577/atomically. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

