## Change Log

### [v1.1.2](https://github.com/khiav223577/atomically/compare/v1.1.1...v1.1.2) 2020/09/01
- [#19](https://github.com/khiav223577/atomically/pull/19) Fix: changed attributes are not updated when calling `atomically.update` (@khiav223577)
- [#18](https://github.com/khiav223577/atomically/pull/18) Support Ruby 2.7 (@khiav223577)
- [#17](https://github.com/khiav223577/atomically/pull/17) specify gem versions by ENV['DB'] (@khiav223577)

### [v1.1.1](https://github.com/khiav223577/atomically/compare/v1.1.0...v1.1.1) 2019/11/01
- [#16](https://github.com/khiav223577/atomically/pull/16) Fix: `create_or_plus` is broken when using `makara` adapter (@khiav223577)

### [v1.1.0](https://github.com/khiav223577/atomically/compare/v1.0.6...v1.1.0) 2019/10/23
- [#12](https://github.com/khiav223577/atomically/pull/12) Support PostgreSQL (@khiav223577)
- [#14](https://github.com/khiav223577/atomically/pull/14) Support Rails 6.0 (@khiav223577)
- [#13](https://github.com/khiav223577/atomically/pull/13) Remove deprecated codeclimate-test-reporter gem (@khiav223577)
- [#11](https://github.com/khiav223577/atomically/pull/11) Fix: Non-attribute arguments will be disallowed in Rails 6.0 (@khiav223577)

### [v1.0.6](https://github.com/khiav223577/atomically/compare/v1.0.5...v1.0.6) 2019/01/28
- [#10](https://github.com/khiav223577/atomically/pull/10) `decrement_unsigned_counters` should be able to decrement the field to zero (@khiav223577)

### [v1.0.5](https://github.com/khiav223577/atomically/compare/v1.0.4...v1.0.5) 2019/01/28
- [#9](https://github.com/khiav223577/atomically/pull/9) Implement `decrement_unsigned_counters` (@khiav223577)
- [#8](https://github.com/khiav223577/atomically/pull/8) Fix: broken test cases after bundler 2.0 was released (@khiav223577)

### [v1.0.4](https://github.com/khiav223577/atomically/compare/v1.0.3...v1.0.4) 2018/12/21
- [#7](https://github.com/khiav223577/atomically/pull/7) Implement `update_all_and_get_ids` (@khiav223577)
- [#6](https://github.com/khiav223577/atomically/pull/6) Add warning (@kakas)
- [#5](https://github.com/khiav223577/atomically/pull/5) fix README `pay_all` description (@kakas)

### [v1.0.3](https://github.com/khiav223577/atomically/compare/v1.0.2...v1.0.3) 2018/11/28
- [#4](https://github.com/khiav223577/atomically/pull/4) Implement `update_all` (@khiav223577)

### [v1.0.2](https://github.com/khiav223577/atomically/compare/v1.0.1...v1.0.2) 2018/11/27
- [#3](https://github.com/khiav223577/atomically/pull/3) Implement `update` (@khiav223577)

### [v1.0.1](https://github.com/khiav223577/atomically/compare/v1.0.0...v1.0.1) 2018/11/22
- [#2](https://github.com/khiav223577/atomically/pull/2) Implement `pay_all` (@khiav223577)
- [#1](https://github.com/khiav223577/atomically/pull/1) Implement `create_or_plus` (@khiav223577)
