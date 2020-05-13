# CHANGELOG
## 1.4.1
New
* Updated for Ruby 2.7+ support
* Switched to Addressable.URI.escape from obsolete URI.escape

## 1.4.0
### New
* Add `encoding` config option (see [All available config options](https://github.com/vifreefly/kimuraframework#all-available-config-options))
* Validate url before processing a request (Base#request_to)

### Fixes
* Fix console command bug (see [issue 21](https://github.com/vifreefly/kimuraframework/issues/21))

## 1.3.2
### Fixes
* In the project template, set Ruby version as >= 2.5 (before was hard-coded to 2.5.1)
* Remove .ruby-version file (was hard-coded to 2.5.1) from the project template

## 1.3.1
### Fixes
* Fixed bug in Base#save_to

## 1.3.0
### Breaking changes 1.3.0
* Remove persistence database feature (because it's slow and makes things complicated)

### New
* Add `--include` and `--exclude` options to CLI#runner
* Add Base `#create_browser` method to easily create additional browser instances
* Add Capybara::Session `#scroll_to_bottom`
* Add skip_on_failure feature to `retry_request_errors` config option
* Add info about `add_event` method to the README

### Fixes and improvements
* Improve Runner
* Fix time helper in schedule.rb
* Add proxy validation to browser builders
* Allow to pass different arguments to the `Base.parse` method

## 1.2.0
### New
* Add possibility to add array of values to the storage (`Base::Storage#add`)
* Add `exception_on_fail` option to `Base.crawl!`
* Add possibility to pass request hash to the `start_urls` (You can use array of hashes as well, like: `@start_urls = [{ url: "https://example.com/cat?id=1", data: { category: "First Category" } }]`)
* Implement `skip_request_errors` config feature. Added [Handle request errors](https://github.com/vifreefly/kimuraframework#handle-request-errors) chapter to the README.
* Add option to choose response type for `Session#current_response` (`:html` default, or `:json`)
* Add option to provide custom chrome and chromedriver paths

### Improvements
* Refactor `Runner`

### Fixes
* Fix `Base#Saver` (automatically create file if it doesn't exists in case of persistence database)
* Do not deep merge config's `headers:` option

## 1.1.0
### Breaking changes 1.1.0
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
