# ApplicationSpider is a default base spider class. You can set here
# default settings for all spiders inherited from ApplicationSpider.
# To generate a new spider, run: `$ kimurai generate spider spider_name`

class ApplicationSpider < Kimurai::Base
  include ApplicationHelper

  # Default engine for spiders (available engines: :mechanize, :poltergeist_phantomjs,
  # :selenium_firefox, :selenium_chrome)
  @engine = :poltergeist_phantomjs

  # Pipelines list, by order.
  # To process item through pipelines pass item to the `send_item` method
  @pipelines = [:validator, :saver]

  # Default config. Set here options which are default for all spiders inherited
  # from ApplicationSpider. Child's class config will be deep merged with this one
  @config = {
    # Custom headers, format: hash. Example: { "some header" => "some value", "another header" => "another value" }
    # Works only for :mechanize and :poltergeist_phantomjs engines (Selenium doesn't allow to set/get headers)
    # headers: {},

    # Custom User Agent, format: string or lambda.
    # Use lambda if you want to rotate user agents before each run:
    # user_agent: -> { ARRAY_OF_USER_AGENTS.sample }
    # Works for all engines
    # user_agent: "Mozilla/5.0 Firefox/61.0",

    # Custom cookies, format: array of hashes.
    # Format for a single cookie: { name: "cookie name", value: "cookie value", domain: ".example.com" }
    # Works for all engines
    # cookies: [],

    # Proxy, format: string or lambda. Format of a proxy string: "ip:port:protocol:user:password"
    # `protocol` can be http or socks5. User and password are optional.
    # Use lambda if you want to rotate proxies before each run:
    # proxy: -> { ARRAY_OF_PROXIES.sample }
    # Works for all engines, but keep in mind that Selenium drivers doesn't support proxies
    # with authorization. Also, Mechanize doesn't support socks5 proxy format (only http)
    # proxy: "3.4.5.6:3128:http:user:pass",

    # If enabled, browser will ignore any https errors. It's handy while using a proxy
    # with self-signed SSL cert (for example Crawlera or Mitmproxy)
    # Also, it will allow to visit webpages with expires SSL certificate.
    # Works for all engines
    ignore_ssl_errors: true,

    # Custom window size, works for all engines
    # window_size: [1366, 768],

    # Skip images downloading if true, works for all engines
    disable_images: true,

    # Selenium engines only: headless mode, `:native` or `:virtual_display` (default is :native)
    # Although native mode has a better performance, virtual display mode
    # sometimes can be useful. For example, some websites can detect (and block)
    # headless chrome, so you can use virtual_display mode instead
    # headless_mode: :native,

    # This option tells the browser not to use a proxy for the provided list of domains or IP addresses.
    # Format: array of strings. Works only for :selenium_firefox and selenium_chrome
    # proxy_bypass_list: [],

    # Option to provide custom SSL certificate. Works only for :poltergeist_phantomjs and :mechanize
    # ssl_cert_path: "path/to/ssl_cert",

    # Inject some JavaScript code to the browser.
    # Format: array of strings, where each string is a path to JS file.
    # Works only for poltergeist_phantomjs engine (Selenium doesn't support JS code injection)
    # extensions: ["lib/code_to_inject.js"],

    # Automatically skip duplicated (already visited) urls when using `request_to` method.
    # Possible values: `true` or `hash` with options.
    # In case of `true`, all visited urls will be added to the storage's scope `:requests_urls`
    # and if url already contains in this scope, request will be skipped.
    # You can configure this setting by providing additional options as hash:
    # `skip_duplicate_requests: { scope: :custom_scope, check_only: true }`, where:
    # `scope:` - use custom scope than `:requests_urls`
    # `check_only:` - if true, then scope will be only checked for url, url will not
    # be added to the scope if scope doesn't contains it.
    # works for all drivers
    # skip_duplicate_requests: true,

    # Automatically skip provided errors while requesting a page.
    # If raised error matches one of the errors in the list, then this error will be caught,
    # and request will be skipped.
    # It is a good idea to skip errors like NotFound(404), etc.
    # Format: array where elements are error classes or/and hashes. You can use hash format
    # for more flexibility: `{ error: "RuntimeError", message: "404 => Net::HTTPNotFound" }`.
    # Provided `message:` will be compared with a full error message using `String#include?`. Also
    # you can use regex instead: `{ error: "RuntimeError", message: /404|403/ }`.
    # skip_request_errors: [{ error: RuntimeError, message: "404 => Net::HTTPNotFound" }],

    # Automatically retry provided errors with a few attempts while requesting a page.
    # If raised error matches one of the errors in the list, then this error will be caught
    # and the request will be processed again within a delay. There are 3 attempts:
    # first: delay 15 sec, second: delay 30 sec, third: delay 45 sec.
    # If after 3 attempts there is still an exception, then the exception will be raised.
    # It is a good idea to try to retry errros like `ReadTimeout`, `HTTPBadGateway`, etc.
    # Format: same like for `skip_request_errors` option.
    # retry_request_errors: [Net::ReadTimeout],

    # Handle page encoding while parsing html response using Nokogiri. There are two modes:
    # Auto (`:auto`) (try to fetch correct encoding from <meta http-equiv="Content-Type"> or <meta charset> tags)
    # Set required encoding manually, example: `encoding: "GB2312"` (Set required encoding manually)
    # Default this option is unset.
    # encoding: nil,

    # Restart browser if one of the options is true:
    restart_if: {
      # Restart browser if provided memory limit (in kilobytes) is exceeded (works for all engines)
      # memory_limit: 350_000,

      # Restart browser if provided requests limit is exceeded (works for all engines)
      # requests_limit: 100
    },

    # Perform several actions before each request:
    before_request: {
      # Change proxy before each request. The `proxy:` option above should be presented
      # and has lambda format. Works only for poltergeist and mechanize engines
      # (Selenium doesn't support proxy rotation).
      # change_proxy: true,

      # Change user agent before each request. The `user_agent:` option above should be presented
      # and has lambda format. Works only for poltergeist and mechanize engines
      # (selenium doesn't support to get/set headers).
      # change_user_agent: true,

      # Clear all cookies before each request, works for all engines
      # clear_cookies: true,

      # If you want to clear all cookies + set custom cookies (`cookies:` option above should be presented)
      # use this option instead (works for all engines)
      # clear_and_set_cookies: true,

      # Global option to set delay between requests.
      # Delay can be `Integer`, `Float` or `Range` (`2..5`). In case of a range,
      # delay number will be chosen randomly for each request: `rand (2..5) # => 3`
      # delay: 1..3
    }
  }
end
