# Kimurai

Kimurai is a modern web scraping framework written in Ruby which **works out of the box with Headless Chromium/Firefox** or simple HTTP requests and **allows you to scrape and interact with JavaScript rendered websites.**

Kimurai is based on the well-known [Capybara](https://github.com/teamcapybara/capybara) and [Nokogiri](https://github.com/sparklemotion/nokogiri) gems, so you don't have to learn anything new. Let's try an example:

```ruby
# github_spider.rb
require 'kimurai'

class GithubSpider < Kimurai::Base
  @name = "github_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://github.com/search?q=ruby+web+scraping&type=repositories"]
  @config = {
    before_request: { delay: 3..5 }
  }

  def parse(response, url:, data: {})
    response.xpath("//div[@data-testid='results-list']//div[contains(@class, 'search-title')]/a").each do |a|
      request_to :parse_repo_page, url: absolute_url(a[:href], base: url)
    end

    if next_page = response.at_xpath("//a[@rel='next']")
      request_to :parse, url: absolute_url(next_page[:href], base: url)
    end
  end

  def parse_repo_page(response, url:, data: {})
    item = {}

    item[:owner] = response.xpath("//a[@rel='author']").text.squish
    item[:repo_name] = response.xpath("//strong[@itemprop='name']").text.squish
    item[:repo_url] = url
    item[:description] = response.xpath("//div[h2[text()='About']]/p").text.squish
    item[:tags] = response.xpath("//div/a[contains(@title, 'Topic')]").map { |a| a.text.squish }
    item[:watch_count] = response.xpath("//div/h3[text()='Watchers']/following-sibling::div[1]/a/strong").text.squish
    item[:star_count] = response.xpath("//div/h3[text()='Stars']/following-sibling::div[1]/a/strong").text.squish
    item[:fork_count] = response.xpath("//div/h3[text()='Forks']/following-sibling::div[1]/a/strong").text.squish
    item[:last_commit] = response.xpath("//div[@data-testid='latest-commit-details']//relative-time/text()").text.squish

    save_to "results.json", item, format: :pretty_json
  end
end

GithubSpider.crawl!
```

<details/>
  <summary>Run: <code>$ ruby github_spider.rb</code></summary>

```
$ ruby github_spider.rb

I, [2025-12-16 12:15:48]  INFO -- github_spider: Spider: started: github_spider
I, [2025-12-16 12:15:48]  INFO -- github_spider: Browser: started get request to: https://github.com/search?q=ruby+web+scraping&type=repositories
I, [2025-12-16 12:16:01]  INFO -- github_spider: Browser: finished get request to: https://github.com/search?q=ruby+web+scraping&type=repositories
I, [2025-12-16 12:16:01]  INFO -- github_spider: Info: visits: requests: 1, responses: 1
I, [2025-12-16 12:16:01]  INFO -- github_spider: Browser: started get request to: https://github.com/sparklemotion/mechanize
I, [2025-12-16 12:16:06]  INFO -- github_spider: Browser: finished get request to: https://github.com/sparklemotion/mechanize
I, [2025-12-16 12:16:06]  INFO -- github_spider: Info: visits: requests: 2, responses: 2
I, [2025-12-16 12:16:06]  INFO -- github_spider: Browser: started get request to: https://github.com/jaimeiniesta/metainspector
I, [2025-12-16 12:16:11]  INFO -- github_spider: Browser: finished get request to: https://github.com/jaimeiniesta/metainspector
I, [2025-12-16 12:16:11]  INFO -- github_spider: Info: visits: requests: 3, responses: 3
I, [2025-12-16 12:16:11]  INFO -- github_spider: Browser: started get request to: https://github.com/Germey/AwesomeWebScraping
I, [2025-12-16 12:16:13]  INFO -- github_spider: Browser: finished get request to: https://github.com/Germey/AwesomeWebScraping
I, [2025-12-16 12:16:13]  INFO -- github_spider: Info: visits: requests: 4, responses: 4
I, [2025-12-16 12:16:13]  INFO -- github_spider: Browser: started get request to: https://github.com/vifreefly/kimuraframework
I, [2025-12-16 12:16:17]  INFO -- github_spider: Browser: finished get request to: https://github.com/vifreefly/kimuraframework

...
```
</details>

<details/>
  <summary>results.json</summary>

```json
[
  {
    "owner": "sparklemotion",
    "repo_name": "mechanize",
    "repo_url": "https://github.com/sparklemotion/mechanize",
    "description": "Mechanize is a ruby library that makes automated web interaction easy.",
    "tags": ["ruby", "web", "scraping"],
    "watch_count": "79",
    "star_count": "4.4k",
    "fork_count": "480",
    "last_commit": "Sep 30, 2025",
    "position": 1
  },
  {
    "owner": "jaimeiniesta",
    "repo_name": "metainspector",
    "repo_url": "https://github.com/jaimeiniesta/metainspector",
    "description": "Ruby gem for web scraping purposes. It scrapes a given URL, and returns you its title, meta description, meta keywords, links, images...",
    "tags": [],
    "watch_count": "20",
    "star_count": "1k",
    "fork_count": "166",
    "last_commit": "Oct 8, 2025",
    "position": 2
  },
  {
    "owner": "Germey",
    "repo_name": "AwesomeWebScraping",
    "repo_url": "https://github.com/Germey/AwesomeWebScraping",
    "description": "List of libraries, tools and APIs for web scraping and data processing.",
    "tags": ["javascript", "ruby", "python", "golang", "php", "awesome", "captcha", "proxy", "web-scraping", "aswsome-list"],
    "watch_count": "5",
    "star_count": "253",
    "fork_count": "33",
    "last_commit": "Apr 5, 2024",
    "position": 3
  },
  {
    "owner": "vifreefly",
    "repo_name": "kimuraframework",
    "repo_url": "https://github.com/vifreefly/kimuraframework",
    "description": "Kimurai is a modern web scraping framework written in Ruby which works out of box with Headless Chromium/Firefox, PhantomJS, or simple HTTP requests and allows to scrape and interact with JavaScript rendered websites",
    "tags": ["crawler", "scraper", "scrapy", "headless-chrome", "kimurai"],
    "watch_count": "28",
    "star_count": "1k",
    "fork_count": "158",
    "last_commit": "Dec 12, 2025",
    "position": 4
  },
  // ...
  {
    "owner": "citixenken",
    "repo_name": "web_scraping_with_ruby",
    "repo_url": "https://github.com/citixenken/web_scraping_with_ruby",
    "description": "",
    "tags": [],
    "watch_count": "1",
    "star_count": "0",
    "fork_count": "0",
    "last_commit": "Aug 29, 2022",
    "position": 118
  }
]
```
</details><br>

Okay, that was easy. How about JavaScript rendered websites with dynamic HTML? Let's scrape a page with infinite scroll:

```ruby
# infinite_scroll_spider.rb
require 'kimurai'

class InfiniteScrollSpider < Kimurai::Base
  @name = "infinite_scroll_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://infinite-scroll.com/demo/full-page/"]

  def parse(response, url:, data: {})
    posts_headers_path = "//article/h2"
    count = response.xpath(posts_headers_path).count

    loop do
      browser.execute_script("window.scrollBy(0,10000)") ; sleep 2
      response = browser.current_response

      new_count = response.xpath(posts_headers_path).count
      if count == new_count
        logger.info "> Pagination is done" and break
      else
        count = new_count
        logger.info "> Continue scrolling, current posts count is #{count}..."
      end
    end

    posts_headers = response.xpath(posts_headers_path).map(&:text)
    logger.info "> All posts from page: #{posts_headers.join('; ')}"
  end
end

InfiniteScrollSpider.crawl!
```

<details/>
  <summary>Run: <code>$ ruby infinite_scroll_spider.rb</code></summary>

```
$ ruby infinite_scroll_spider.rb

I, [2025-12-16 12:47:05]  INFO -- infinite_scroll_spider: Spider: started: infinite_scroll_spider
I, [2025-12-16 12:47:05]  INFO -- infinite_scroll_spider: Browser: started get request to: https://infinite-scroll.com/demo/full-page/
I, [2025-12-16 12:47:09]  INFO -- infinite_scroll_spider: Browser: finished get request to: https://infinite-scroll.com/demo/full-page/
I, [2025-12-16 12:47:09]  INFO -- infinite_scroll_spider: Info: visits: requests: 1, responses: 1
I, [2025-12-16 12:47:11]  INFO -- infinite_scroll_spider: > Continue scrolling, current posts count is 5...
I, [2025-12-16 12:47:13]  INFO -- infinite_scroll_spider: > Continue scrolling, current posts count is 9...
I, [2025-12-16 12:47:15]  INFO -- infinite_scroll_spider: > Continue scrolling, current posts count is 11...
I, [2025-12-16 12:47:17]  INFO -- infinite_scroll_spider: > Continue scrolling, current posts count is 13...
I, [2025-12-16 12:47:19]  INFO -- infinite_scroll_spider: > Continue scrolling, current posts count is 15...
I, [2025-12-16 12:47:21]  INFO -- infinite_scroll_spider: > Pagination is done
I, [2025-12-16 12:47:21]  INFO -- infinite_scroll_spider: > All posts from page: 1a - Infinite Scroll full page demo; 1b - RGB Schemes logo in Computer Arts; 2a - RGB Schemes logo; 2b - Masonry gets horizontalOrder; 2c - Every vector 2016; 3a - Logo Pizza delivered; 3b - Some CodePens; 3c - 365daysofmusic.com; 3d - Holograms; 4a - Huebee: 1-click color picker; 4b - Word is Flickity is good; Flickity v2 released: groupCells, adaptiveHeight, parallax; New tech gets chatter; Isotope v3 released: stagger in, IE8 out; Packery v2 released
I, [2025-12-16 12:47:21]  INFO -- infinite_scroll_spider: Browser: driver selenium_chrome has been destroyed
I, [2025-12-16 12:47:21]  INFO -- infinite_scroll_spider: Spider: stopped: {spider_name: "infinite_scroll_spider", status: :completed, error: nil, environment: "development", start_time: 2025-12-16 12:47:05.372053 +0300, stop_time: 2025-12-16 12:47:21.505078 +0300, running_time: "16s", visits: {requests: 1, responses: 1}, items: {sent: 0, processed: 0}, events: {requests_errors: {}, drop_items_errors: {}, custom: {}}}
```
</details><br>


## Features
* Scrape JavaScript rendered websites out of the box
* Supported engines: [Headless Chrome](https://developers.google.com/web/updates/2017/04/headless-chrome), [Headless Firefox](https://developer.mozilla.org/en-US/docs/Mozilla/Firefox/Headless_mode) or simple HTTP requests ([mechanize](https://github.com/sparklemotion/mechanize) gem)
* Write spider code once, and use it with any supported engine later
* All the power of [Capybara](https://github.com/teamcapybara/capybara): use methods like `click_on`, `fill_in`, `select`, `choose`, `set`, `go_back`, etc. to interact with web pages
* Rich [configuration](#spider-config): **set default headers, cookies, delay between requests, enable proxy/user-agents rotation**
* Built-in helpers to make scraping easy, like [save_to](#save_to-helper) (save items to JSON, JSON lines, or CSV formats) or [unique?](#skip-duplicates) to skip duplicates
* Automatically [handle requests errors](#handle-request-errors)
* Automatically restart browsers when reaching memory limit [**(memory control)**](#spider-config) or requests limit
* Easily [schedule spiders](#schedule-spiders-using-cron) within cron using [Whenever](https://github.com/javan/whenever) (no need to know cron syntax)
* [Parallel scraping](#parallel-crawling-using-in_parallel) using simple method `in_parallel`
* **Two modes:** use single file for a simple spider, or [generate](#project-mode) Scrapy-like **project**
* Convenient development mode with [console](#interactive-console), colorized logger and debugger ([Pry](https://github.com/pry/pry), [Byebug](https://github.com/deivid-rodriguez/byebug))
* Command-line [runner](#runner) to run all project spiders one-by-one or in parallel

## Table of Contents
* [Kimurai](#kimurai)
  * [Features](#features)
  * [Table of Contents](#table-of-contents)
  * [Installation](#installation)
  * [Getting to know Kimurai](#getting-to-know-kimurai)
    * [Interactive console](#interactive-console)
    * [Available engines](#available-engines)
    * [Minimum required spider structure](#minimum-required-spider-structure)
    * [Method arguments response, url and data](#method-arguments-response-url-and-data)
    * [browser object](#browser-object)
    * [request_to method](#request_to-method)
    * [save_to helper](#save_to-helper)
    * [Skip duplicates](#skip-duplicates)
      * [Automatically skip all duplicate request urls](#automatically-skip-all-duplicate-request-urls)
      * [Storage object](#storage-object)
    * [Handling request errors](#handling-request-errors)
      * [skip_request_errors](#skip_request_errors)
      * [retry_request_errors](#retry_request_errors)
    * [Logging custom events](#logging-custom-events)
    * [open_spider and close_spider callbacks](#open_spider-and-close_spider-callbacks)
    * [KIMURAI_ENV](#kimurai_env)
    * [Parallel crawling using in_parallel](#parallel-crawling-using-in_parallel)
    * [Active Support included](#active-support-included)
    * [Schedule spiders using Cron](#schedule-spiders-using-cron)
    * [Configuration options](#configuration-options)
    * [Using Kimurai inside existing Ruby applications](#using-kimurai-inside-existing-ruby-applications)
      * [crawl! method](#crawl-method)
      * [parse! method](#parsemethod_name-url-method)
      * [Kimurai.list and Kimurai.find_by_name](#kimurailist-and-kimuraifind_by_name)
  * [Spider @config](#spider-config)
    * [All available @config options](#all-available-config-options)
    * [@config settings inheritance](#config-settings-inheritance)
  * [Project mode](#project-mode)
    * [Generate new spider](#generate-new-spider)
    * [Crawl](#crawl)
    * [List](#list)
    * [Parse](#parse)
    * [Pipelines, send_item method](#pipelines-send_item-method)
    * [Runner](#runner)
      * [Runner callbacks](#runner-callbacks)
  * [Chat Support and Feedback](#chat-support-and-feedback)
  * [License](#license)


## Installation
Kimurai requires Ruby version `>= 3.1.0`. Officially supported platforms: `Linux` and `macOS`.

1) If your system doesn't have the appropriate Ruby version, install it:

<details/>
  <summary>Ubuntu 24.04</summary>

```bash
# Install required system packages
sudo apt update
sudo apt install build-essential rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev

# Install Mice version manager
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate)"' >> ~/.bashrc
source ~/.bashrc

# Install latest Ruby
mise use --global ruby@3
gem update --system
```
</details>

<details/>
  <summary>macOS</summary>

```bash
# Install Homebrew if you don't have it https://brew.sh/
brew install openssl@3 libyaml gmp rust

# Install Mice version manager
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate)"' >> ~/.zshrc
source ~/.zshrc

# Install latest Ruby
mise use --global ruby@3
gem update --system
```
</details>

2) Install Kimurai gem: `$ gem install kimurai`

3) Install browsers:

<details/>
  <summary>Ubuntu 24.04</summary>

```bash
# Install basic tools
sudo apt install -q -y unzip wget tar openssl

# Install xvfb (for virtual_display headless mode, in addition to native)
sudo apt install -q -y xvfb
```

Latest automatically installed selenium drivers doesn't work well with Ubuntu Snap versions of Chrome and Firefox, therefore we need to install classic .deb versions and make sure they are available over Snap versions:

```bash
# Install google chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y ./google-chrome-stable_current_amd64.deb
```

```bash
# Install firefox (only if you intend to use Firefox as a browser, using selenium_firefox engine)
# See https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
sudo snap remove firefox

sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/mozilla

sudo apt update && sudo apt remove firefox
sudo apt install firefox
```
</details>

<details/>
  <summary>macOS</summary>

```bash
# Install google chrome
brew install google-chrome 
```

```bash
# Install firefox (only if you intend to use Firefox as a browser, using selenium_firefox engine)
brew install firefox
```
</details><br>

## Getting to know Kimurai
### Interactive console
Before you get to know all of Kimurai's features, there is a `$ kimurai console` command which is an interactive console where you can try and debug your scraping code very quickly, without having to run any spider (yes, it's like [Scrapy shell](https://doc.scrapy.org/en/latest/topics/shell.html#topics-shell)).

```bash
$ kimurai console --engine selenium_chrome --url https://github.com/vifreefly/kimuraframework
```

<details/>
  <summary>Show output</summary>

```
$ kimurai console --engine selenium_chrome --url https://github.com/vifreefly/kimuraframework

D, [2025-12-16 13:08:41 +0300#37718] [M: 1208] DEBUG -- : BrowserBuilder (selenium_chrome): created browser instance
I, [2025-12-16 13:08:41 +0300#37718] [M: 1208]  INFO -- : Browser: started get request to: https://github.com/vifreefly/kimuraframework
I, [2025-12-16 13:08:43 +0300#37718] [M: 1208]  INFO -- : Browser: finished get request to: https://github.com/vifreefly/kimuraframework

From: /Users/vic/code/spiders/kimuraframework/lib/kimurai/base.rb:208 Kimurai::Base#console:

    207: def console(response = nil, url: nil, data: {})
 => 208:   binding.pry
    209: end

[1] pry(#<Kimurai::Base>)> response.css('title').text
=> "GitHub - vifreefly/kimuraframework: Kimurai is a modern Ruby web scraping framework that supports scraping with antidetect Chrome/Firefox as well as HTTP requests"
[2] pry(#<Kimurai::Base>)> browser.current_url
=> "https://github.com/vifreefly/kimuraframework"
[3] pry(#<Kimurai::Base>)> browser.visit('https://google.com')
I, [2025-12-16 13:09:24 +0300#37718] [M: 1208]  INFO -- : Browser: started get request to: https://google.com
I, [2025-12-16 13:09:26 +0300#37718] [M: 1208]  INFO -- : Browser: finished get request to: https://google.com
=> true
[4] pry(#<Kimurai::Base>)> browser.current_response.title
=> "Google"
```
</details><br>

CLI arguments:
* `--engine` (optional) [engine](#available-drivers) to use. Default is `mechanize`
* `--url` (optional) url to process. If url is omitted, `response` and `url` objects inside the console will be `nil` (use [browser](#browser-object) object to navigate to any webpage).

### Available engines
Kimurai has support for the following engines and can mostly switch between them without the need to rewrite any code:

* `:mechanize` – [pure Ruby fake http browser](https://github.com/sparklemotion/mechanize). Mechanize can't render JavaScript and doesn't know what the DOM is it. It can only parse the original HTML code of a page. Because of it, mechanize is much faster, takes much less memory and is in general much more stable than any real browser. It's recommended to use mechanize when possible; if the website doesn't use JavaScript to render any meaningful parts of its structure. Still, because mechanize is trying to mimic a real browser, it supports almost all of Capybara's [methods to interact with a web page](http://cheatrags.com/capybara) (filling forms, clicking buttons, checkboxes, etc).
* `:selenium_chrome` – Chrome in headless mode driven by selenium. A modern headless browser solution with proper JavaScript rendering.
* `:selenium_firefox` – Firefox in headless mode driven by selenium. Usually takes more memory than other drivers, but can sometimes be useful.

**Tip:** prepend a `HEADLESS=false` environment variable on the command line (i.e. `$ HEADLESS=false ruby spider.rb`) to launch an interactive browser in normal (not headless) mode and see its window (only for selenium-like engines). It works for the [console](#interactive-console) command as well.


### Minimum required spider structure
> You can manually create a spider file, or use the generate command: `$ kimurai generate spider simple_spider`

```ruby
require 'kimurai'

class SimpleSpider < Kimurai::Base
  @name = "simple_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://example.com/"]

  def parse(response, url:, data: {})
  end
end

SimpleSpider.crawl!
```

Where:
* `@name` – a name for the spider
* `@engine` – engine to use for the spider
* `@start_urls` – array of urls to process one-by-one inside the `parse` method
* The `parse` method is the entry point, and should always be present in a spider class


### Method arguments `response`, `url` and `data`

```ruby
def parse(response, url:, data: {})
end
```

* `response` – [Nokogiri::HTML::Document](https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/HTML/Document) object – contains parsed HTML code of a processed webpage
* `url` – String – url of a processed webpage
* `data` – Hash – used to pass data between requests

<details/>
  <summary><strong>An example of how to use <code>data</code></strong></summary>

Imagine that there is a product page that doesn't contain a category name. The category name is only present on category pages with pagination. This is a case where we can use `data` to pass a category name from `parse` to `parse_product`:

```ruby
class ProductsSpider < Kimurai::Base
  @engine = :selenium_chrome
  @start_urls = ["https://example-shop.com/example-product-category"]

  def parse(response, url:, data: {})
    category_name = response.xpath("//path/to/category/name").text
    response.xpath("//path/to/products/urls").each do |product_url|
      # Merge category_name with current data hash and pass it to parse_product
      request_to(:parse_product, url: product_url[:href], data: data.merge(category_name: category_name))
    end

    # ...
  end

  def parse_product(response, url:, data: {})
    item = {}
    # Assign an item's category_name from data[:category_name]
    item[:category_name] = data[:category_name]

    # ...
  end
end

```
</details><br>

**You can query `response` using [XPath or CSS selectors](https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Searchable)**. Check Nokogiri tutorials to understand how to work with `response`:
* [Parsing HTML with Nokogiri](http://ruby.bastardsbook.com/chapters/html-parsing/) – ruby.bastardsbook.com
* [HOWTO parse HTML with Ruby & Nokogiri](https://readysteadycode.com/howto-parse-html-with-ruby-and-nokogiri) – readysteadycode.com
* [Class: Nokogiri::HTML::Document](https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/HTML/Document) (documentation) – rubydoc.info


### `browser` object

A browser object is available from any spider instance method, which is a [Capybara::Session](https://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session) object and uses it to process requests and get page responses (`current_response` method). Usually, you don't need to touch it directly because `response` (see above) contains the page response after it was loaded.

But, if you need to interact with a page (like filling form fields, clicking elements, checkboxes, etc) a `browser` is ready for you:

```ruby
class GoogleSpider < Kimurai::Base
  @name = "google_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://www.google.com/"]

  def parse(response, url:, data: {})
    browser.fill_in "q", with: "Kimurai web scraping framework"
    browser.click_button "Google Search"

    # Update response with current_response after interaction with a browser
    response = browser.current_response

    # Collect results
    results = response.xpath("//div[@class='g']//h3/a").map do |a|
      { title: a.text, url: a[:href] }
    end

    # ...
  end
end
```

Check out **Capybara cheat sheets** where you can see all available methods **to interact with browser**:
* [UI Testing with RSpec and Capybara [cheat sheet]](http://cheatrags.com/capybara) – cheatrags.com
* [Capybara Cheatsheet PDF](https://thoughtbot.com/upcase/test-driven-rails-resources/capybara.pdf) – thoughtbot.com
* [Class: Capybara::Session](https://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session) (documentation) – rubydoc.info

### `request_to` method

For making requests to a particular method, there is `request_to`. It requires at least two arguments: `:method_name` and `url:`. And, optionally `data:` (see above). Example:

```ruby
class Spider < Kimurai::Base
  @engine = :selenium_chrome
  @start_urls = ["https://example.com/"]

  def parse(response, url:, data: {})
    # Process request to `parse_product` method with `https://example.com/some_product` url:
    request_to :parse_product, url: "https://example.com/some_product"
  end

  def parse_product(response, url:, data: {})
    puts "From page https://example.com/some_product !"
  end
end
```

Under the hood, `request_to` simply calls [#visit](https://www.rubydoc.info/github/jnicklas/capybara/Capybara%2FSession:visit) (`browser.visit(url)`), and the provided method with arguments:

<details/>
  <summary>request_to</summary>

```ruby
def request_to(handler, url:, data: {})
  request_data = { url: url, data: data }

  browser.visit(url)
  public_send(handler, browser.current_response, request_data)
end
```
</details><br>

The `request_to` helper method makes things simpler. We could also do something like:

<details/>
  <summary>See the code</summary>

```ruby
class Spider < Kimurai::Base
  @engine = :selenium_chrome
  @start_urls = ["https://example.com/"]

  def parse(response, url:, data: {})
    url_to_process = "https://example.com/some_product"

    browser.visit(url_to_process)
    parse_product(browser.current_response, url: url_to_process)
  end

  def parse_product(response, url:, data: {})
    puts "From page https://example.com/some_product !"
  end
end
```
</details>

### `save_to` helper

Sometimes all you need is to simply save scraped data to a file. You can use the `save_to` helper method like so:

```ruby
class ProductsSpider < Kimurai::Base
  @engine = :selenium_chrome
  @start_urls = ["https://example-shop.com/"]

  # ...

  def parse_product(response, url:, data: {})
    item = {}

    item[:title] = response.xpath("//title/path").text
    item[:description] = response.xpath("//desc/path").text.squish
    item[:price] = response.xpath("//price/path").text[/\d+/]&.to_f

    # Append each new item to the `scraped_products.json` file:
    save_to "scraped_products.json", item, format: :json
  end
end
```

Supported formats:
* `:json` – JSON
* `:pretty_json` – "pretty" JSON (`JSON.pretty_generate`)
* `:jsonlines` – [JSON Lines](http://jsonlines.org/)
* `:csv` – CSV

Note: `save_to` requires the data (item) to save to be a `Hash`.

By default, `save_to` will add a position key to an item hash. You can disable it like so: `save_to "scraped_products.json", item, format: :json, position: false`

**How helper works:**

While the spider is running, each new item will be appended to the output file. On the next run, this helper will clear the contents of the output file, then start appending items to it.

> If you don't want the file to be cleared before each run, pass `append: true` like so: `save_to "scraped_products.json", item, format: :json, append: true`

### Skip duplicates

It's pretty common for websites to have duplicate pages. For example, when an e-commerce site has the same products in different categories. To skip duplicates, there is a simple `unique?` helper:

```ruby
class ProductsSpider < Kimurai::Base
  @engine = :selenium_chrome
  @start_urls = ["https://example-shop.com/"]

  def parse(response, url:, data: {})
    response.xpath("//categories/path").each do |category|
      request_to :parse_category, url: category[:href]
    end
  end

  # Check products for uniqueness using product url inside of parse_category:
  def parse_category(response, url:, data: {})
    response.xpath("//products/path").each do |product|
      # Skip url if it's not unique:
      next unless unique?(:product_url, product[:href])
      # Otherwise process it:
      request_to :parse_product, url: product[:href]
    end
  end

  # And/or check products for uniqueness using product sku inside of parse_product:
  def parse_product(response, url:, data: {})
    item = {}
    item[:sku] = response.xpath("//product/sku/path").text.strip.upcase
    # Don't save the product if there is already an item with the same sku:
    return unless unique?(:sku, item[:sku])

    # ...
    save_to "results.json", item, format: :json
  end
end
```

The `unique?` helper works quite simply:

```ruby
# Check for "http://example.com" in `url` scope for the first time:
unique?(:url, "http://example.com")
# => true

# Next time:
unique?(:url, "http://example.com")
# => false
```

To check something for uniqueness, you need to provide a scope:

```ruby
# `product_url` scope
unique?(:product_url, "http://example.com/product_1")

# `id` scope
unique?(:id, 324234232)

# `custom` scope
unique?(:custom, "Lorem Ipsum")
```

#### Automatically skip all duplicate request urls

It's possible to automatically skip any previously visited urls when calling the `request_to` method using the `skip_duplicate_requests: true` config option. See [@config](#all-available-config-options) for additional options.

#### `storage` object

The `unique?` method is just an alias for `storage#unique?`. Storage has several methods:

* `#all` – return all scopes
* `#add(scope, value)` – add a value to the scope
* `#include?(scope, value)` – returns `true` if the value exists in the scope, or `false` if it doesn't
* `#unique?(scope, value)` – returns `false` if the value exists in the scope, otherwise adds the value to the scope and returns  `true`
* `#clear!` – deletes all values from all scopes


### Handling request errors
It's common while crawling web pages to get response codes other than `200 OK`. In such cases, the `request_to` method (or `browser.visit`) can raise an exception. Kimurai provides the `skip_request_errors` and `retry_request_errors` [config](#spider-config) options to handle such errors:

#### skip_request_errors
Kimurai can automatically skip certain errors while performing requests using the `skip_request_errors` [config](#spider-config) option. If a raised error matches one of the errors in the list, the error will be caught, and the request will be skipped. It's a good idea to skip errors like `404 Not Found`, etc.

`skip_request_errors` is an array of error classes and/or hashes. You can use a _hash_ for more flexibility like so:

```
@config = {
  skip_request_errors: [{ error: RuntimeError, message: "404 => Net::HTTPNotFound" }, { error: TimeoutError }]
}
```
In this case, the provided `message:` will be compared with a full error message using `String#include?`. You can also use regex like so: `{ error: RuntimeError, message: /404|403/ }`.

#### retry_request_errors
Kimurai can automatically retry requests several times after certain errors with the `retry_request_errors` [config](#spider-config) option. If a raised error matches one of the errors in the list, the error will be caught, and the request will be processed again with progressive delay.

There are 3 attempts with _15 sec_, _30 sec_, and _45 sec_ delays, respectively. If after 3 attempts there is still an exception, then the exception will be raised. It's a good idea to retry errors like `ReadTimeout`, `HTTPBadGateway`, etc.

The format for `retry_request_errors` is the same as for `skip_request_errors`.

If you would like to skip (not raise) the error after the 3 retries, you can specify `skip_on_failure: true` like so:

```ruby
@config = {
  retry_request_errors: [{ error: RuntimeError, skip_on_failure: true }]
}
```

### Logging custom events

It's possible to save custom messages to the [run_info](#open_spider-and-close_spider-callbacks) hash using the `add_event('Some message')` method. This feature helps you to keep track of important events during crawling without checking the whole spider log (in case if you're logging these messages using `logger`). For example:

```ruby
def parse_product(response, url:, data: {})
  unless response.at_xpath("//path/to/add_to_card_button")
    add_event("Product is sold") and return
  end

  # ...
end
```

```
...
I, [2018-11-28 22:20:19 +0400#7402] [M: 47156576560640]  INFO -- example_spider: Spider: new event (scope: custom): Product is sold
...
I, [2018-11-28 22:20:19 +0400#7402] [M: 47156576560640]  INFO -- example_spider: Spider: stopped: {:events=>{:custom=>{"Product is sold"=>1}}}
```

### `open_spider` and `close_spider` callbacks

You can define `.open_spider` and `.close_spider` callbacks (class methods) to perform some action(s) before or after the spider runs:

```ruby
require 'kimurai'

class ExampleSpider < Kimurai::Base
  @name = "example_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://example.com/"]

  def self.open_spider
    logger.info "> Starting..."
  end

  def self.close_spider
    logger.info "> Stopped!"
  end

  def parse(response, url:, data: {})
    logger.info "> Scraping..."
  end
end

ExampleSpider.crawl!
```

<details/>
  <summary>Output</summary>

```
I, [2018-08-22 14:26:32 +0400#6001] [M: 46996522083840]  INFO -- example_spider: Spider: started: example_spider
I, [2018-08-22 14:26:32 +0400#6001] [M: 46996522083840]  INFO -- example_spider: > Starting...
D, [2018-08-22 14:26:32 +0400#6001] [M: 46996522083840] DEBUG -- example_spider: BrowserBuilder (selenium_chrome): created browser instance
D, [2018-08-22 14:26:32 +0400#6001] [M: 46996522083840] DEBUG -- example_spider: BrowserBuilder (selenium_chrome): enabled native headless_mode
I, [2018-08-22 14:26:32 +0400#6001] [M: 46996522083840]  INFO -- example_spider: Browser: started get request to: https://example.com/
I, [2018-08-22 14:26:34 +0400#6001] [M: 46996522083840]  INFO -- example_spider: Browser: finished get request to: https://example.com/
I, [2018-08-22 14:26:34 +0400#6001] [M: 46996522083840]  INFO -- example_spider: Info: visits: requests: 1, responses: 1
D, [2018-08-22 14:26:34 +0400#6001] [M: 46996522083840] DEBUG -- example_spider: Browser: driver.current_memory: 82415
I, [2018-08-22 14:26:34 +0400#6001] [M: 46996522083840]  INFO -- example_spider: > Scraping...
I, [2018-08-22 14:26:34 +0400#6001] [M: 46996522083840]  INFO -- example_spider: Browser: driver selenium_chrome has been destroyed
I, [2018-08-22 14:26:34 +0400#6001] [M: 46996522083840]  INFO -- example_spider: > Stopped!
I, [2018-08-22 14:26:34 +0400#6001] [M: 46996522083840]  INFO -- example_spider: Spider: stopped: {:spider_name=>"example_spider", :status=>:completed, :environment=>"development", :start_time=>2018-08-22 14:26:32 +0400, :stop_time=>2018-08-22 14:26:34 +0400, :running_time=>"1s", :visits=>{:requests=>1, :responses=>1}, :error=>nil}
```
</details><br>

The `run_info` method is available from the `open_spider` and `close_spider` class methods. It contains useful information about the spider state:

```ruby
    11: def self.open_spider
 => 12:   binding.pry
    13: end

[1] pry(example_spider)> run_info
=> {
  :spider_name=>"example_spider",
  :status=>:running,
  :environment=>"development",
  :start_time=>2018-08-05 23:32:00 +0400,
  :stop_time=>nil,
  :running_time=>nil,
  :visits=>{:requests=>0, :responses=>0},
  :error=>nil
}
```

`run_info` will be updated from `close_spider`:

```ruby
    15: def self.close_spider
 => 16:   binding.pry
    17: end

[1] pry(example_spider)> run_info
=> {
  :spider_name=>"example_spider",
  :status=>:completed,
  :environment=>"development",
  :start_time=>2018-08-05 23:32:00 +0400,
  :stop_time=>2018-08-05 23:32:06 +0400,
  :running_time=>6.214,
  :visits=>{:requests=>1, :responses=>1},
  :error=>nil
}
```

`run_info[:status]` helps to determine if the spider finished successfully or failed (possible values: `:completed`, `:failed`):

```ruby
class ExampleSpider < Kimurai::Base
  @name = "example_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://example.com/"]

  def self.close_spider
    puts ">>> run info: #{run_info}"
  end

  def parse(response, url:, data: {})
    logger.info "> Scraping..."
    # Let's try to strip nil:
    nil.strip
  end
end
```

<details/>
  <summary>Output</summary>

```
I, [2018-08-22 14:34:24 +0400#8459] [M: 47020523644400]  INFO -- example_spider: Spider: started: example_spider
D, [2018-08-22 14:34:25 +0400#8459] [M: 47020523644400] DEBUG -- example_spider: BrowserBuilder (selenium_chrome): created browser instance
D, [2018-08-22 14:34:25 +0400#8459] [M: 47020523644400] DEBUG -- example_spider: BrowserBuilder (selenium_chrome): enabled native headless_mode
I, [2018-08-22 14:34:25 +0400#8459] [M: 47020523644400]  INFO -- example_spider: Browser: started get request to: https://example.com/
I, [2018-08-22 14:34:26 +0400#8459] [M: 47020523644400]  INFO -- example_spider: Browser: finished get request to: https://example.com/
I, [2018-08-22 14:34:26 +0400#8459] [M: 47020523644400]  INFO -- example_spider: Info: visits: requests: 1, responses: 1
D, [2018-08-22 14:34:26 +0400#8459] [M: 47020523644400] DEBUG -- example_spider: Browser: driver.current_memory: 83351
I, [2018-08-22 14:34:26 +0400#8459] [M: 47020523644400]  INFO -- example_spider: > Scraping...
I, [2018-08-22 14:34:26 +0400#8459] [M: 47020523644400]  INFO -- example_spider: Browser: driver selenium_chrome has been destroyed

>>> run info: {:spider_name=>"example_spider", :status=>:failed, :environment=>"development", :start_time=>2018-08-22 14:34:24 +0400, :stop_time=>2018-08-22 14:34:26 +0400, :running_time=>2.01, :visits=>{:requests=>1, :responses=>1}, :error=>"#<NoMethodError: undefined method `strip' for nil:NilClass>"}

F, [2018-08-22 14:34:26 +0400#8459] [M: 47020523644400] FATAL -- example_spider: Spider: stopped: {:spider_name=>"example_spider", :status=>:failed, :environment=>"development", :start_time=>2018-08-22 14:34:24 +0400, :stop_time=>2018-08-22 14:34:26 +0400, :running_time=>"2s", :visits=>{:requests=>1, :responses=>1}, :error=>"#<NoMethodError: undefined method `strip' for nil:NilClass>"}
Traceback (most recent call last):
        6: from example_spider.rb:19:in `<main>'
        5: from /home/victor/code/kimurai/lib/kimurai/base.rb:127:in `crawl!'
        4: from /home/victor/code/kimurai/lib/kimurai/base.rb:127:in `each'
        3: from /home/victor/code/kimurai/lib/kimurai/base.rb:128:in `block in crawl!'
        2: from /home/victor/code/kimurai/lib/kimurai/base.rb:185:in `request_to'
        1: from /home/victor/code/kimurai/lib/kimurai/base.rb:185:in `public_send'
example_spider.rb:15:in `parse': undefined method `strip' for nil:NilClass (NoMethodError)
```
</details><br>

**Usage example:** if the spider finished successfully, send a JSON file with scraped items to a remote FTP location, otherwise (if the spider failed), skip incompleted results and send an email/notification to Slack about it:

<details/>
  <summary>Example</summary>

You can also use the additional methods `completed?` or `failed?`

```ruby
class Spider < Kimurai::Base
  @engine = :selenium_chrome
  @start_urls = ["https://example.com/"]

  def self.close_spider
    if completed?
      send_file_to_ftp("results.json")
    else
      send_error_notification(run_info[:error])
    end
  end

  def self.send_file_to_ftp(file_path)
    # ...
  end

  def self.send_error_notification(error)
    # ...
  end

  # ...

  def parse_item(response, url:, data: {})
    item = {}
    # ...

    save_to "results.json", item, format: :json
  end
end
```
</details>


### `KIMURAI_ENV`
Kimurai supports environments. The default is `development`. To provide a custom environment provide a `KIMURAI_ENV` environment variable like so: `$ KIMURAI_ENV=production ruby spider.rb`. To access the current environment there is a `Kimurai.env` method.

Usage example:
```ruby
class Spider < Kimurai::Base
  @engine = :selenium_chrome
  @start_urls = ["https://example.com/"]

  def self.close_spider
    if failed? && Kimurai.env == "production"
      send_error_notification(run_info[:error])
    else
      # Do nothing
    end
  end

  # ...
end
```

### Parallel crawling using `in_parallel`
Kimurai can process web pages concurrently: `in_parallel(:parse_product, urls, threads: 3)`, where `:parse_product` is a method to process, `urls` is an array of urls to crawl and `threads:` is a number of threads:

```ruby
# amazon_spider.rb
require 'kimurai'

class AmazonSpider < Kimurai::Base
  @name = "amazon_spider"
  @engine = :mechanize
  @start_urls = ["https://www.amazon.com/"]

  def parse(response, url:, data: {})
    browser.fill_in "field-keywords", with: "Web Scraping Books"
    browser.click_on "Go"

    # Walk through pagination and collect product urls:
    urls = []
    loop do
      response = browser.current_response
      response.xpath("//li//a[contains(@class, 's-access-detail-page')]").each do |a|
        urls << a[:href].sub(/ref=.+/, "")
      end

      browser.find(:xpath, "//a[@id='pagnNextLink']", wait: 1).click rescue break
    end

    # Process all collected urls concurrently using 3 threads:
    in_parallel(:parse_book_page, urls, threads: 3)
  end

  def parse_book_page(response, url:, data: {})
    item = {}

    item[:title] = response.xpath("//h1/span[@id]").text.squish
    item[:url] = url
    item[:price] = response.xpath("(//span[contains(@class, 'a-color-price')])[1]").text.squish.presence
    item[:publisher] = response.xpath("//h2[text()='Product details']/following::b[text()='Publisher:']/following-sibling::text()[1]").text.squish.presence

    save_to "books.json", item, format: :pretty_json
  end
end

AmazonSpider.crawl!
```

<details/>
  <summary>Run: <code>$ ruby amazon_spider.rb</code></summary>

```
$ ruby amazon_spider.rb

...

I, [2025-12-16 13:48:19 +0300#39167] [C: 1624]  INFO -- amazon_spider: Info: visits: requests: 305, responses: 305
I, [2025-12-16 13:48:19 +0300#39167] [C: 1624]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Real-World-Python-Hackers-Solving-Problems/dp/1718500629/
I, [2025-12-16 13:48:22 +0300#39167] [C: 1624]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Real-World-Python-Hackers-Solving-Problems/dp/1718500629/
I, [2025-12-16 13:48:22 +0300#39167] [C: 1624]  INFO -- amazon_spider: Info: visits: requests: 306, responses: 306
I, [2025-12-16 13:48:22 +0300#39167] [C: 1624]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Introduction-Important-efficient-collection-scraping-ebook/dp/B0D2MLXFT6/
I, [2025-12-16 13:48:23 +0300#39167] [C: 1624]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Introduction-Important-efficient-collection-scraping-ebook/dp/B0D2MLXFT6/
I, [2025-12-16 13:48:23 +0300#39167] [C: 1624]  INFO -- amazon_spider: Info: visits: requests: 307, responses: 307
I, [2025-12-16 13:48:23 +0300#39167] [C: 1624]  INFO -- amazon_spider: Browser: driver mechanize has been destroyed
I, [2025-12-16 13:48:23 +0300#39167] [M: 1152]  INFO -- amazon_spider: Spider: in_parallel: stopped processing 306 urls within 3 threads, total time: 2m, 37s
I, [2025-12-16 13:48:23 +0300#39167] [M: 1152]  INFO -- amazon_spider: Browser: driver mechanize has been destroyed
I, [2025-12-16 13:48:23 +0300#39167] [M: 1152]  INFO -- amazon_spider: Spider: stopped: {spider_name: "amazon_spider", status: :completed, error: nil, environment: "development", start_time: 2025-12-16 13:45:12.5338 +0300, stop_time: 2025-12-16 13:48:23.526221 +0300, running_time: "3m, 10s", visits: {requests: 307, responses: 307}, items: {sent: 0, processed: 0}, events: {requests_errors: {}, drop_items_errors: {}, custom: {}}}
vic@Vics-MacBook-Air single % 

```
</details>

<details/>
  <summary>books.json</summary>

```json
[
  {
    "title": "Web Scraping with Python: Data Extraction from the Modern Web 3rd Edition",
    "url": "https://www.amazon.com/Web-Scraping-Python-Extraction-Modern/dp/1098145356/",
    "price": "$27.00",
    "author": "Ryan Mitchell",
    "publication_date": "March 26, 2024",
    "position": 1
  },
  {
    "title": "Web Scraping with Python: Collecting More Data from the Modern Web 2nd Edition",
    "url": "https://www.amazon.com/Web-Scraping-Python-Collecting-Modern/dp/1491985577/",
    "price": "$13.20 - $38.15",
    "author": "Ryan Mitchell",
    "publication_date": "May 8, 2018",
    "position": 2
  },
  {
    "title": "Scripting: Automation with Bash, PowerShell, and Python—Automate Everyday IT Tasks from Backups to Web Scraping in Just a Few Lines of Code (Rheinwerk Computing) First Edition",
    "url": "https://www.amazon.com/Scripting-Automation-Bash-PowerShell-Python/dp/1493225561/",
    "price": "$47.02",
    "author": "Michael Kofler",
    "publication_date": "February 25, 2024",
    "position": 3
  },

  // ...
  
  {
    "title": "Introduction to Python Important points for efficient data collection with scraping (Japanese Edition) Kindle Edition",
    "url": "https://www.amazon.com/Introduction-Important-efficient-collection-scraping-ebook/dp/B0D2MLXFT6/",
    "price": "$0.00",
    "author": "r",
    "publication_date": "April 24, 2024",
    "position": 306
  }
]
```
</details><br>

> Note that [save_to](#save_to-helper) and [unique?](#skip-duplicates-unique-helper) helpers are thread-safe (protected by [Mutex](https://ruby-doc.org/core-2.5.1/Mutex.html)) and can be freely used inside threads.

`in_parallel` can take additional parameters:

* `data:` – pass custom data like so: `in_parallel(:method, urls, threads: 3, data: { category: "Scraping" })`
* `delay:` – set delay between requests like so: `in_parallel(:method, urls, threads: 3, delay: 2)`. Delay can be `Integer`, `Float` or `Range` (`2..5`). In case of a Range, the delay (in seconds) will be set randomly for each request: `rand (2..5) # => 3`
* `engine:` – set custom engine like so: `in_parallel(:method, urls, threads: 3, engine: :selenium_chrome)`
* `config:` – set custom [config](#spider-config) options

### Active Support included

You can use all the power of familiar [Rails core-ext methods](https://guides.rubyonrails.org/active_support_core_extensions.html#loading-all-core-extensions) for scraping inside Kimurai. Especially take a look at [squish](https://apidock.com/rails/String/squish), [truncate_words](https://apidock.com/rails/String/truncate_words), [titleize](https://apidock.com/rails/String/titleize), [remove](https://apidock.com/rails/String/remove), [present?](https://guides.rubyonrails.org/active_support_core_extensions.html#blank-questionmark-and-present-questionmark) and [presence](https://guides.rubyonrails.org/active_support_core_extensions.html#presence).

### Schedule spiders using Cron

1) Inside the spider directory generate a [Whenever](https://github.com/javan/whenever) schedule configuration like so: `$ kimurai generate schedule`.

<details/>
  <summary><code>schedule.rb</code></summary>

```ruby
### Settings ###
require 'tzinfo'

# Export current PATH for cron
env :PATH, ENV["PATH"]

# Use 24 hour format when using `at:` option
set :chronic_options, hours24: true

# Use local_to_utc helper to setup execution time using your local timezone instead
# of server's timezone (which is probably and should be UTC, to check run `$ timedatectl`).
# You should also set the same timezone in kimurai (use `Kimurai.configuration.time_zone =` for that).
#
# Example usage of helper:
# every 1.day, at: local_to_utc("7:00", zone: "Europe/Moscow") do
#   crawl "google_spider.com", output: "log/google_spider.com.log"
# end
def local_to_utc(time_string, zone:)
  TZInfo::Timezone.get(zone).local_to_utc(Time.parse(time_string))
end

# Note: by default Whenever exports cron commands with :environment == "production".
# Note: Whenever can only append log data to a log file (>>). If you want
# to overwrite (>) a log file before each run, use lambda notation:
# crawl "google_spider.com", output: -> { "> log/google_spider.com.log 2>&1" }

# Project job types
job_type :crawl,  "cd :path && KIMURAI_ENV=:environment bundle exec kimurai crawl :task :output"
job_type :runner, "cd :path && KIMURAI_ENV=:environment bundle exec kimurai runner --jobs :task :output"

# Single file job type
job_type :single, "cd :path && KIMURAI_ENV=:environment ruby :task :output"
# Single with bundle exec
job_type :single_bundle, "cd :path && KIMURAI_ENV=:environment bundle exec ruby :task :output"

### Schedule ###
# Usage (see examples here https://github.com/javan/whenever#example-schedulerb-file):
# every 1.day do
  # Example to schedule a single spider in the project:
  # crawl "google_spider.com", output: "log/google_spider.com.log"

  # Example to schedule all spiders in the project using runner. Each spider will write
  # its own output to the `log/spider_name.log` file (handled by runner itself).
  # Runner output will be written to log/runner.log

  # Example to schedule single spider (without a project):
  # single "single_spider.rb", output: "single_spider.log"
# end

### How to set up a cron schedule ###
# Run: `$ whenever --update-crontab --load-file config/schedule.rb`.
# If you don't have the whenever command, install the gem like so: `$ gem install whenever`.

### How to cancel a schedule ###
# Run: `$ whenever --clear-crontab --load-file config/schedule.rb`.
```
</details><br>

2) At the bottom of `schedule.rb`, add the following code:

```ruby
every 1.day, at: "7:00" do
  single "example_spider.rb", output: "example_spider.log"
end
```

3) Run: `$ whenever --update-crontab --load-file schedule.rb`. Done!

You can see some [Whenever](https://github.com/javan/whenever) examples [here](https://github.com/javan/whenever#example-schedulerb-file). To cancel a schedule, run: `$ whenever --clear-crontab --load-file schedule.rb`.

### Configuration options
You can configure several options inside the `configure` block:

```ruby
Kimurai.configure do |config|
  # The default logger has colorized mode enabled in development.
  # If you would like to disable it, set `colorize_logger` to false.
  # config.colorize_logger = false

  # Logger level for default logger:
  # config.log_level = :info

  # Custom logger:
  # config.logger = Logger.new(STDOUT)

  # Custom time zone (for logs):
  # config.time_zone = "UTC"
  # config.time_zone = "Europe/Moscow"

  # Provide custom chrome binary path (default is any available chrome/chromium in the PATH):
  # config.selenium_chrome_path = "/usr/bin/chromium-browser"
  # Provide custom selenium chromedriver path (default is "/usr/local/bin/chromedriver"):
  # config.chromedriver_path = "~/.local/bin/chromedriver"
end
```

### Using Kimurai inside existing Ruby applications

You can integrate Kimurai spiders (which are just Ruby classes) into an existing Ruby application like Rails or Sinatra, and run them using background jobs, for example. See the following sections to understand the process of running spiders:

#### `.crawl!` method

`.crawl!` (class method) performs a _full run_ of a particular spider. This method will return run_info if it was successful, or an exception if something went wrong.

```ruby
class ExampleSpider < Kimurai::Base
  @name = "example_spider"
  @engine = :mechanize
  @start_urls = ["https://example.com/"]

  def parse(response, url:, data: {})
    title = response.xpath("//title").text.squish
  end
end

ExampleSpider.crawl!
# => { :spider_name => "example_spider", :status => :completed, :environment => "development", :start_time => 2018-08-22 18:20:16 +0400, :stop_time => 2018-08-22 18:20:17 +0400, :running_time => 1.216, :visits => { :requests => 1, :responses => 1 }, :items => { :sent => 0, :processed => 0 }, :error => nil }
```

You can't `.crawl!` a spider in a different thread if it's still running (because spider instances store some shared data in the `@run_info` class variable while `crawl`ing):

```ruby
2.times do |i|
  Thread.new { p i, ExampleSpider.crawl! }
end # =>

# 1
# false

# 0
# {:spider_name=>"example_spider", :status=>:completed, :environment=>"development", :start_time=>2018-08-22 18:49:22 +0400, :stop_time=>2018-08-22 18:49:23 +0400, :running_time=>0.801, :visits=>{:requests=>1, :responses=>1}, :items=>{:sent=>0, :processed=>0}, :error=>nil}
```

So, what if you don't care about stats and just want to process a request with a particular spider method and get the return value from this method? Use `.parse!` instead:

#### `.parse!(:method_name, url:)` method

The `.parse!` (class method) creates a new spider instance and performs a request with the provided method and url. The value from the method will be returned back:

```ruby
class ExampleSpider < Kimurai::Base
  @name = "example_spider"
  @engine = :mechanize
  @start_urls = ["https://example.com/"]

  def parse(response, url:, data: {})
    title = response.xpath("//title").text.squish
  end
end

ExampleSpider.parse!(:parse, url: "https://example.com/")
# => "Example Domain"
```

Like `.crawl!`, the `.parse!` method creates a browser instance and destroys it (`browser.destroy_driver!`) before returning the value. Unlike `.crawl!`, `.parse!` method can be called from different threads at the same time:

```ruby
urls = ["https://www.google.com/", "https://www.reddit.com/", "https://en.wikipedia.org/"]

urls.each do |url|
  Thread.new { p ExampleSpider.parse!(:parse, url: url) }
end # =>

# "Google"
# "Wikipedia, the free encyclopedia"
# "reddit: the front page of the internetHotHot"
```

Keep in mind, that [save_to](#save_to-helper) and [unique?](#skip-duplicates) helpers are not thread-safe while using the `.parse!` method.

#### `Kimurai.list` and `Kimurai.find_by_name()`

```ruby
class GoogleSpider < Kimurai::Base
  @name = "google_spider"
end

class RedditSpider < Kimurai::Base
  @name = "reddit_spider"
end

class WikipediaSpider < Kimurai::Base
  @name = "wikipedia_spider"
end

# To get the list of all available spider classes:
Kimurai.list
# => {"google_spider"=>GoogleSpider, "reddit_spider"=>RedditSpider, "wikipedia_spider"=>WikipediaSpider}

# To find a particular spider class by its name:
Kimurai.find_by_name("reddit_spider")
# => RedditSpider
```

## Spider `@config`

Using `@config` you can set several options for a spider; such as proxy, user-agent, default cookies/headers, delay between requests, browser **memory control** and so on:

```ruby
class Spider < Kimurai::Base
  USER_AGENTS = ["Chrome", "Firefox", "Safari", "Opera"]
  PROXIES = ["2.3.4.5:8080:http:username:password", "3.4.5.6:3128:http", "1.2.3.4:3000:socks5"]

  @engine = :selenium_chrome
  @start_urls = ["https://example.com/"]
  @config = {
    headers: { "custom_header" => "custom_value" },
    cookies: [{ name: "cookie_name", value: "cookie_value", domain: ".example.com" }],
    user_agent: -> { USER_AGENTS.sample },
    proxy: -> { PROXIES.sample },
    window_size: [1366, 768],
    disable_images: true,
    restart_if: {
      # Restart browser if provided memory limit (in kilobytes) is exceeded:
      memory_limit: 350_000
    },
    before_request: {
      # Change user agent before each request:
      change_user_agent: true,
      # Change proxy before each request:
      change_proxy: true,
      # Clear all cookies and set default cookies (if provided) before each request:
      clear_and_set_cookies: true,
      # Set a delay before each request:
      delay: 1..3
    }
  }

  def parse(response, url:, data: {})
    # ...
  end
end
```

### All available `@config` options

```ruby
@config = {
  # Custom headers hash. Example: { "some header" => "some value", "another header" => "another value" }
  # Works for :mechanize. Selenium doesn't support setting headers.
  headers: {},

  # Custom User Agent – string or lambda
  #
  # Use lambda if you want to rotate user agents before each run:
  # 	user_agent: -> { ARRAY_OF_USER_AGENTS.sample }
  #
  # Works for all engines
  user_agent: "Mozilla/5.0 Firefox/61.0",

  # Custom cookies – an array of hashes
  # Format for a single cookie: { name: "cookie name", value: "cookie value", domain: ".example.com" }
  #
  # Works for all engines
  cookies: [],

  # Proxy – string or lambda. Format for a proxy string: "ip:port:protocol:user:password"
  # 	`protocol` can be http or socks5. User and password are optional.
  #
  # Use lambda if you want to rotate proxies before each run:
  # 	proxy: -> { ARRAY_OF_PROXIES.sample }
  #
  # Works for all engines, but keep in mind that Selenium drivers don't support proxies
  # with authorization. Also, Mechanize doesn't support socks5 proxy format (only http).
  proxy: "3.4.5.6:3128:http:user:pass",

  # If enabled, browser will ignore any https errors. It's handy while using a proxy
  # with a self-signed SSL cert (for example Crawlera or Mitmproxy). It will allow you to
  # visit web pages with expired SSL certificates.
  #
  # Works for all engines
  ignore_ssl_errors: true,

  # Custom window size, works for all engines
  window_size: [1366, 768],

  # Skip loading images if true, works for all engines. Speeds up page load time.
  disable_images: true,

  # For Selenium engines only: headless mode, `:native` or `:virtual_display` (default is :native)
  # Although native mode has better performance, virtual display mode
  # can sometimes be useful. For example, some websites can detect (and block)
  # headless chrome, so you can use virtual_display mode instead.
  headless_mode: :native,

  # This option tells the browser not to use a proxy for the provided list of domains or IP addresses.
  # Format: array of strings. Works only for :selenium_firefox and selenium_chrome.
  proxy_bypass_list: [],

  # Option to provide custom SSL certificate. Works only for :mechanize.
  ssl_cert_path: "path/to/ssl_cert",

  # Inject some JavaScript code into the browser.
  # Format: array of strings, where each string is a path to a JS file or extension directory
  # Selenium doesn't support JS code injection.
  extensions: ["lib/code_to_inject.js"],

  # Automatically skip already visited urls when using `request_to` method
  #
  # Possible values: `true` or a hash with options
  # In case of `true`, all visited urls will be added to the storage scope `:requests_urls`
  # and if the url already exists in this scope, the request will be skipped.
  #
  # You can configure this setting by providing additional options as hash:
  # 	`skip_duplicate_requests: { scope: :custom_scope, check_only: true }`, where:
  # 		`scope:` – use a custom scope other than `:requests_urls`
  # 		`check_only:` – if true, the url will not be added to the scope
  # 		
  # Works for all drivers
  skip_duplicate_requests: true,

  # Automatically skip provided errors while requesting a page
  #
  # If a raised error matches one of the errors in the list, then the error will be caught,
  # and the request will be skipped. It's a good idea to skip errors like 404 Not Found, etc.
  #
  # Format: array where elements are error classes and/or hashes. You can use a hash
  # for more flexibility: `{ error: "RuntimeError", message: "404 => Net::HTTPNotFound" }`.
  #
  # The provided `message:` will be compared with a full error message using `String#include?`.
  # You can also use regex: `{ error: "RuntimeError", message: /404|403/ }`.
  skip_request_errors: [{ error: RuntimeError, message: "404 => Net::HTTPNotFound" }],
  
  # Automatically retry requests several times after certain errors
  #
  # If a raised error matches one of the errors in the list, the error will be caught,
  # and the request will be processed again with progressive delay.
  #
  # There are 3 attempts with _15 sec_, _30 sec_, and _45 sec_ delays, respectively. If after 3
  # attempts there is still an exception, then the exception will be raised. It's a good idea to
  # retry errors like `ReadTimeout`, `HTTPBadGateway`, etc.
  #
  # The format for `retry_request_errors` is the same as for `skip_request_errors`.
  retry_request_errors: [Net::ReadTimeout],

  # Handle page encoding while parsing html response using Nokogiri
  #
  # There are two ways to use this option:
  # 	encoding: :auto # auto-detect from <meta http-equiv="Content-Type"> or <meta charset> tags
  #		encoding: "GB2312" # set encoding manually
  #
  # This option is not set by default
  encoding: nil,

  # Restart browser if one of the options is true:
  restart_if: {
    # Restart browser if provided memory limit (in kilobytes) is exceeded (works for all engines)
    memory_limit: 1_500_000,

    # Restart browser if provided requests limit is exceeded (works for all engines)
    requests_limit: 100
  },

  # Perform several actions before each request:
  before_request: {
    # Change proxy before each request. The `proxy:` option above should be set with lambda notation.
    # Works for :mechanize engine. Selenium doesn't support proxy rotation.
    change_proxy: true,

    # Change user agent before each request. The `user_agent:` option above should set with lambda
    # notation. Works for :mechanize engine. Selenium doesn't support setting headers.
    change_user_agent: true,

    # Clear all cookies before each request. Works for all engines.
    clear_cookies: true,

    # If you want to clear all cookies and set custom cookies, the `cookies:` option above should be set
    # Use this option instead of clear_cookies. Works for all engines.
    clear_and_set_cookies: true,

    # Global option to set delay between requests
    #
    # Delay can be `Integer`, `Float` or `Range` (`2..5`). In case of a range,
    # the delay (in seconds) will be set randomly for each request: `rand (2..5) # => 3`
    delay: 1..3
  }
}
```

As you can see, most of the options are universal for any engine.

### `@config` settings inheritance
Settings can be inherited:

```ruby
class ApplicationSpider < Kimurai::Base
  @engine = :selenium_chrome
  @config = {
    user_agent: "Chrome",
    disable_images: true,
    restart_if: { memory_limit: 1_500_000 },
    before_request: { delay: 1..2 }
  }
end

class CustomSpider < ApplicationSpider
  @name = "custom_spider"
  @start_urls = ["https://example.com/"]
  @config = {
    before_request: { delay: 4..6 }
  }

  def parse(response, url:, data: {})
    # ...
  end
end
```

Here, `@config` of `CustomSpider` will be _[deep merged](https://apidock.com/rails/Hash/deep_merge)_ with `ApplicationSpider`'s' config. In this example, `CustomSpider` will keep all inherited options with only the `delay` being updated.

## Project mode

Kimurai can work in project mode ([Like Scrapy](https://doc.scrapy.org/en/latest/intro/tutorial.html#creating-a-project)). To generate a new project, run: `$ kimurai generate project web_spiders` (where `web_spiders` is the name for the project).

Structure of the project:

```bash
.
├── config/
│   ├── initializers/
│   ├── application.rb
│   ├── boot.rb
│   └── schedule.rb
├── spiders/
│   └── application_spider.rb
├── db/
├── helpers/
│   └── application_helper.rb
├── lib/
├── log/
├── pipelines/
│   ├── validator.rb
│   └── saver.rb
├── tmp/
├── .env
├── Gemfile
├── Gemfile.lock
└── README.md
```

<details/>
  <summary>Description</summary>

* `config/` – directory for configutation files
  * `config/initializers` – [Rails-like initializers](https://guides.rubyonrails.org/configuring.html#using-initializer-files) to load custom code when the framework initializes
  * `config/application.rb` – configuration settings for Kimurai (`Kimurai.configure do` block)
  * `config/boot.rb`–  loads framework and project
  * `config/schedule.rb` – Cron [schedule for spiders](#schedule-spiders-using-cron)
* `spiders/` – directory for spiders
  * `spiders/application_spider.rb` – base parent class for all spiders
* `db/` – directory for database files (`sqlite`, `json`, `csv`, etc.)
* `helpers/` – Rails-like helpers for spiders
  * `helpers/application_helper.rb` – all methods inside the ApplicationHelper module will be available for all spiders
* `lib/` – custom Ruby code
* `log/` – directory for logs
* `pipelines/` – directory for [Scrapy-like](https://doc.scrapy.org/en/latest/topics/item-pipeline.html) pipelines (one file per pipeline)
  * `pipelines/validator.rb` – example pipeline to validate an item
  * `pipelines/saver.rb` – example pipeline to save an item
* `tmp/` – folder for temp files
* `.env` – file to store environment variables for a project and load them using [Dotenv](https://github.com/bkeepers/dotenv)
* `Gemfile` – dependency file
* `Readme.md` – example project readme
</details>


### Generate new spider
To generate a new spider in the project, run:

```bash
$ kimurai generate spider example_spider
      create  spiders/example_spider.rb
```

Command will generate a new spider class inherited from `ApplicationSpider`:

```ruby
class ExampleSpider < ApplicationSpider
  @name = "example_spider"
  @start_urls = []
  @config = {}

  def parse(response, url:, data: {})
  end
end
```

### Crawl
To run a particular spider in the project, run: `$ bundle exec kimurai crawl example_spider`. Don't forget to add `bundle exec` before command to load required environment.

### List
To list all project spiders, run: `$ bundle exec kimurai list`

### Parse
For project spiders you can use `$ kimurai parse` command which helps to debug spiders:

```bash
$ bundle exec kimurai parse example_spider parse_product --url https://example-shop.com/product-1
```

where `example_spider` is a spider to run, `parse_product` is a spider method to process and `--url` is url to open inside processing method.

### Pipelines, `send_item` method
You can use item pipelines to organize and store in one place item processing logic for all project spiders (also check Scrapy [description of pipelines](https://doc.scrapy.org/en/latest/topics/item-pipeline.html#item-pipeline)).

Imagine if you have three spiders where each of them crawls different e-commerce shop and saves only shoe positions. For each spider, you want to save items only with "shoe" category, unique sku, valid title/price and with existing images. To avoid code duplication between spiders, use pipelines:

<details/>
  <summary>Example</summary>

pipelines/validator.rb
```ruby
class Validator < Kimurai::Pipeline
  def process_item(item, options: {})
    # Here you can validate item and raise `DropItemError`
    # if one of the validations failed. Examples:

    # Drop item if its category is not "shoe":
    if item[:category] != "shoe"
      raise DropItemError, "Wrong item category"
    end

    # Check item sku for uniqueness using buit-in unique? helper:
    unless unique?(:sku, item[:sku])
      raise DropItemError, "Item sku is not unique"
    end

    # Drop item if title length shorter than 5 symbols:
    if item[:title].size < 5
      raise DropItemError, "Item title is short"
    end

    # Drop item if price is not present
    unless item[:price].present?
      raise DropItemError, "item price is not present"
    end

    # Drop item if it doesn't contains any images:
    unless item[:images].present?
      raise DropItemError, "Item images are not present"
    end

    # Pass item to the next pipeline (if it wasn't dropped):
    item
  end
end

```

pipelines/saver.rb
```ruby
class Saver < Kimurai::Pipeline
  def process_item(item, options: {})
    # Here you can save item to the database, send it to a remote API or
    # simply save item to a file format using `save_to` helper:

    # To get the name of current spider: `spider.class.name`
    save_to "db/#{spider.class.name}.json", item, format: :json

    item
  end
end
```

spiders/application_spider.rb
```ruby
class ApplicationSpider < Kimurai::Base
  @engine = :selenium_chrome
  
  # Define pipelines (by order) for all spiders:
  @pipelines = [:validator, :saver]
end
```

spiders/shop_spider_1.rb
```ruby
class ShopSpiderOne < ApplicationSpider
  @name = "shop_spider_1"
  @start_urls = ["https://shop-1.com"]

  # ...

  def parse_product(response, url:, data: {})
    # ...

    # Send item to pipelines:
    send_item item
  end
end
```

spiders/shop_spider_2.rb
```ruby
class ShopSpiderTwo < ApplicationSpider
  @name = "shop_spider_2"
  @start_urls = ["https://shop-2.com"]

  def parse_product(response, url:, data: {})
    # ...

    # Send item to pipelines:
    send_item item
  end
end
```

spiders/shop_spider_3.rb
```ruby
class ShopSpiderThree < ApplicationSpider
  @name = "shop_spider_3"
  @start_urls = ["https://shop-3.com"]

  def parse_product(response, url:, data: {})
    # ...

    # Send item to pipelines:
    send_item item
  end
end
```
</details><br>

When you start using pipelines, there are stats for items appears:

<details>
  <summary>Example</summary>

pipelines/validator.rb
```ruby
class Validator < Kimurai::Pipeline
  def process_item(item, options: {})
    if item[:star_count] < 10
      raise DropItemError, "Repository doesn't have enough stars"
    end

    item
  end
end
```

spiders/github_spider.rb
```ruby
class GithubSpider < Kimurai::Base
  @name = "github_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://github.com/search?q=ruby+web+scraping&type=repositories"]
  @config = {
    before_request: { delay: 3..5 }
  }

  def parse(response, url:, data: {})
    response.xpath("//div[@data-testid='results-list']//div[contains(@class, 'search-title')]/a").each do |a|
      request_to :parse_repo_page, url: absolute_url(a[:href], base: url)
    end

    if next_page = response.at_xpath("//a[@rel='next']")
      request_to :parse, url: absolute_url(next_page[:href], base: url)
    end
  end

  def parse_repo_page(response, url:, data: {})
    item = {}

    item[:owner] = response.xpath("//a[@rel='author']").text.squish
    item[:repo_name] = response.xpath("//strong[@itemprop='name']").text.squish
    item[:repo_url] = url
    item[:description] = response.xpath("//div[h2[text()='About']]/p").text.squish
    item[:tags] = response.xpath("//div/a[contains(@title, 'Topic')]").map { |a| a.text.squish }
    item[:watch_count] = response.xpath("//div/h3[text()='Watchers']/following-sibling::div[1]/a/strong").text.squish
    item[:star_count] = response.xpath("//div/h3[text()='Stars']/following-sibling::div[1]/a/strong").text.squish
    item[:fork_count] = response.xpath("//div/h3[text()='Forks']/following-sibling::div[1]/a/strong").text.squish
    item[:last_commit] = response.xpath("//div[@data-testid='latest-commit-details']//relative-time/text()").text.squish

    save_to "results.json", item, format: :pretty_json
  end
end
```

```
$ bundle exec kimurai crawl github_spider

I, [2018-08-22 15:56:35 +0400#1358]  INFO -- github_spider: Spider: started: github_spider
D, [2018-08-22 15:56:35 +0400#1358] DEBUG -- github_spider: BrowserBuilder (selenium_chrome): created browser instance
I, [2018-08-22 15:56:40 +0400#1358]  INFO -- github_spider: Browser: started get request to: https://github.com/search?q=Ruby%20Web%20Scraping
I, [2018-08-22 15:56:44 +0400#1358]  INFO -- github_spider: Browser: finished get request to: https://github.com/search?q=Ruby%20Web%20Scraping
I, [2018-08-22 15:56:44 +0400#1358]  INFO -- github_spider: Info: visits: requests: 1, responses: 1
D, [2018-08-22 15:56:44 +0400#1358] DEBUG -- github_spider: Browser: driver.current_memory: 116182
D, [2018-08-22 15:56:44 +0400#1358] DEBUG -- github_spider: Browser: sleep 5 seconds before request...

I, [2018-08-22 15:56:49 +0400#1358]  INFO -- github_spider: Browser: started get request to: https://github.com/lorien/awesome-web-scraping
I, [2018-08-22 15:56:50 +0400#1358]  INFO -- github_spider: Browser: finished get request to: https://github.com/lorien/awesome-web-scraping
I, [2018-08-22 15:56:50 +0400#1358]  INFO -- github_spider: Info: visits: requests: 2, responses: 2
D, [2018-08-22 15:56:50 +0400#1358] DEBUG -- github_spider: Browser: driver.current_memory: 217432
D, [2018-08-22 15:56:50 +0400#1358] DEBUG -- github_spider: Pipeline: starting processing item through 1 pipeline...
I, [2018-08-22 15:56:50 +0400#1358]  INFO -- github_spider: Pipeline: processed: {"owner":"lorien","repo_name":"awesome-web-scraping","repo_url":"https://github.com/lorien/awesome-web-scraping","description":"List of libraries, tools and APIs for web scraping and data processing.","tags":["awesome","awesome-list","web-scraping","data-processing","python","javascript","php","ruby"],"watch_count":159,"star_count":2423,"fork_count":358,"last_commit":"4 days ago"}
I, [2018-08-22 15:56:50 +0400#1358]  INFO -- github_spider: Info: items: sent: 1, processed: 1
D, [2018-08-22 15:56:50 +0400#1358] DEBUG -- github_spider: Browser: sleep 6 seconds before request...

...

I, [2018-08-22 16:11:50 +0400#1358]  INFO -- github_spider: Browser: started get request to: https://github.com/preston/idclight
I, [2018-08-22 16:11:51 +0400#1358]  INFO -- github_spider: Browser: finished get request to: https://github.com/preston/idclight
I, [2018-08-22 16:11:51 +0400#1358]  INFO -- github_spider: Info: visits: requests: 140, responses: 140
D, [2018-08-22 16:11:51 +0400#1358] DEBUG -- github_spider: Browser: driver.current_memory: 211713

D, [2018-08-22 16:11:51 +0400#1358] DEBUG -- github_spider: Pipeline: starting processing item through 1 pipeline...
E, [2018-08-22 16:11:51 +0400#1358] ERROR -- github_spider: Pipeline: dropped: #<Kimurai::Pipeline::DropItemError: Repository doesn't have enough stars>, item: {:owner=>"preston", :repo_name=>"idclight", :repo_url=>"https://github.com/preston/idclight", :description=>"A Ruby gem for accessing the freely available IDClight (IDConverter Light) web service, which convert between different types of gene IDs such as Hugo and Entrez. Queries are screen scraped from http://idclight.bioinfo.cnio.es.", :tags=>[], :watch_count=>6, :star_count=>1, :fork_count=>0, :last_commit=>"on Apr 12, 2012"}

I, [2018-08-22 16:11:51 +0400#1358]  INFO -- github_spider: Info: items: sent: 127, processed: 12

I, [2018-08-22 16:11:51 +0400#1358]  INFO -- github_spider: Browser: driver selenium_chrome has been destroyed
I, [2018-08-22 16:11:51 +0400#1358]  INFO -- github_spider: Spider: stopped: {:spider_name=>"github_spider", :status=>:completed, :environment=>"development", :start_time=>2018-08-22 15:56:35 +0400, :stop_time=>2018-08-22 16:11:51 +0400, :running_time=>"15m, 16s", :visits=>{:requests=>140, :responses=>140}, :items=>{:sent=>127, :processed=>12}, :error=>nil}
```
</details><br>

You can also pass custom options to a pipeline from a particular spider if you want to change the pipeline behavior for this spider:

<details>
  <summary>Example</summary>

spiders/custom_spider.rb
```ruby
class CustomSpider < ApplicationSpider
  @name = "custom_spider"
  @start_urls = ["https://example.com"]
  @pipelines = [:validator]

  # ...

  def parse_item(response, url:, data: {})
    # ...

    # Pass custom option `skip_uniq_checking` for Validator pipeline:
    send_item item, validator: { skip_uniq_checking: true }
  end
end

```

pipelines/validator.rb
```ruby
class Validator < Kimurai::Pipeline
  def process_item(item, options: {})

    # Do not check item sku for uniqueness if options[:skip_uniq_checking] is true
    if options[:skip_uniq_checking] != true
      raise DropItemError, "Item sku is not unique" unless unique?(:sku, item[:sku])
    end
  end
end
```
</details>


### Runner

You can run project spiders one by one or in parallel using `$ kimurai runner` command:

```
$ bundle exec kimurai list
custom_spider
example_spider
github_spider

$ bundle exec kimurai runner -j 3
>>> Runner: started: {:id=>1533727423, :status=>:processing, :start_time=>2018-08-08 15:23:43 +0400, :stop_time=>nil, :environment=>"development", :concurrent_jobs=>3, :spiders=>["custom_spider", "github_spider", "example_spider"]}
> Runner: started spider: custom_spider, index: 0
> Runner: started spider: github_spider, index: 1
> Runner: started spider: example_spider, index: 2
< Runner: stopped spider: custom_spider, index: 0
< Runner: stopped spider: example_spider, index: 2
< Runner: stopped spider: github_spider, index: 1
<<< Runner: stopped: {:id=>1533727423, :status=>:completed, :start_time=>2018-08-08 15:23:43 +0400, :stop_time=>2018-08-08 15:25:11 +0400, :environment=>"development", :concurrent_jobs=>3, :spiders=>["custom_spider", "github_spider", "example_spider"]}
```

Each spider runs in a separate process. Spider logs are available in the `log/` directory. Use the `-j` argument to specify how many spiders should be processed at the same time (default is 1).

You can provide additional arguments like `--include` or `--exclude` to specify which spiders to run:

```bash
# Run only custom_spider and example_spider:
$ bundle exec kimurai runner --include custom_spider example_spider

# Run all except github_spider:
$ bundle exec kimurai runner --exclude github_spider
```

#### Runner callbacks

You can perform custom actions before runner starts and after runner stops using `config.runner_at_start_callback` and `config.runner_at_stop_callback`. Check [config/application.rb](lib/kimurai/template/config/application.rb) to see example.


## Chat Support and Feedback
Submit an issue on GitHub and we'll try to address it in a timely manner.

## License
This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
