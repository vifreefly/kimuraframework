# CHANGELOG
## 1.1.0
### Breaking changes 1.0.1
`browser` config option depricated. Now all sub-options inside `browser` should be placed right into `@config` hash, without `browser` parent key. Example:

```ruby
# Was:
@config = {
  browser: {
    retry_request_errors: [Net::ReadTimeout],
    restart_if: {
      memory_limit: 350_000,
      requests_limit: 100
    },
    before_request: {
      change_proxy: true,
      change_user_agent: true,
      clear_cookies: true,
      clear_and_set_cookies: true,
      delay: 1..3
    }
  }
}

# Now:
@config = {
  retry_request_errors: [Net::ReadTimeout],
  restart_if: {
    memory_limit: 350_000,
    requests_limit: 100
  },
  before_request: {
    change_proxy: true,
    change_user_agent: true,
    clear_cookies: true,
    clear_and_set_cookies: true,
    delay: 1..3
  }
}
```

### New
* Add `storage` object with additional methods and persistence database feature
* Add events feature to `run_info`
* Add `skip_duplicate_requests` config option to automatically skip already visited urls when using requrst_to
* Add  `extensions` config option to allow inject JS code into browser (supported only by poltergeist_phantomjs engine)
* Add Capybara::Session#within_new_window_by method

### Improvements
* Add the last backtrace line to pipeline output when item was dropped
* Do not destroy driver if it's not exists (for Base.parse! method)
* Handle possible Net::ReadTimeout error while trying to #quit driver

### Fixes
* Fix Mechanize::Driver#proxy (there was a bug while using proxy for mechanize engine without authorization)
* Fix requests retries logic


## 1.0.1
* Add missing `logger` method to pipeline
* Fix `set_proxy` in Mechanize and Poltergeist builders
