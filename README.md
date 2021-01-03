# Kimurai

> UPD. I will soon have a time to work on issues for current 1.4 version and also plan to release new 2.0 version with https://github.com/twalpole/apparition engine.

Kimurai is a modern web scraping framework written in Ruby which **works out of box with Headless Chromium/Firefox, PhantomJS**, or simple HTTP requests and **allows to scrape and interact with JavaScript rendered websites.**

Kimurai based on well-known [Capybara](https://github.com/teamcapybara/capybara) and [Nokogiri](https://github.com/sparklemotion/nokogiri) gems, so you don't have to learn anything new. Lets see:

```ruby
# github_spider.rb
require 'kimurai'

class GithubSpider < Kimurai::Base
  @name = "github_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://github.com/search?q=Ruby%20Web%20Scraping"]
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    before_request: { delay: 4..7 }
  }

  def parse(response, url:, data: {})
    response.xpath("//ul[@class='repo-list']//a[@class='v-align-middle']").each do |a|
      request_to :parse_repo_page, url: absolute_url(a[:href], base: url)
    end

    if next_page = response.at_xpath("//a[@class='next_page']")
      request_to :parse, url: absolute_url(next_page[:href], base: url)
    end
  end

  def parse_repo_page(response, url:, data: {})
    item = {}

    item[:owner] = response.xpath("//h1//a[@rel='author']").text
    item[:repo_name] = response.xpath("//h1/strong[@itemprop='name']/a").text
    item[:repo_url] = url
    item[:description] = response.xpath("//span[@itemprop='about']").text.squish
    item[:tags] = response.xpath("//div[starts-with(@class, 'list-topics-container')]/a").map { |a| a.text.squish }
    item[:watch_count] = response.xpath("//ul[@class='pagehead-actions']/li[contains(., 'Watch')]/a[2]").text.squish
    item[:star_count] = response.xpath("//ul[@class='pagehead-actions']/li[contains(., 'Star')]/a[2]").text.squish
    item[:fork_count] = response.xpath("//ul[@class='pagehead-actions']/li[contains(., 'Fork')]/a[2]").text.squish
    item[:last_commit] = response.xpath("//span[@itemprop='dateModified']/*").text

    save_to "results.json", item, format: :pretty_json
  end
end

GithubSpider.crawl!
```

<details/>
  <summary>Run: <code>$ ruby github_spider.rb</code></summary>

```
I, [2018-08-22 13:08:03 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Spider: started: github_spider
D, [2018-08-22 13:08:03 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: BrowserBuilder (selenium_chrome): created browser instance
D, [2018-08-22 13:08:03 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: BrowserBuilder (selenium_chrome): enabled `browser before_request delay`
D, [2018-08-22 13:08:03 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: Browser: sleep 7 seconds before request...
D, [2018-08-22 13:08:10 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: BrowserBuilder (selenium_chrome): enabled custom user-agent
D, [2018-08-22 13:08:10 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: BrowserBuilder (selenium_chrome): enabled native headless_mode
I, [2018-08-22 13:08:10 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Browser: started get request to: https://github.com/search?q=Ruby%20Web%20Scraping
I, [2018-08-22 13:08:26 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Browser: finished get request to: https://github.com/search?q=Ruby%20Web%20Scraping
I, [2018-08-22 13:08:26 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Info: visits: requests: 1, responses: 1
D, [2018-08-22 13:08:27 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: Browser: driver.current_memory: 107968
D, [2018-08-22 13:08:27 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: Browser: sleep 5 seconds before request...
I, [2018-08-22 13:08:32 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Browser: started get request to: https://github.com/lorien/awesome-web-scraping
I, [2018-08-22 13:08:33 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Browser: finished get request to: https://github.com/lorien/awesome-web-scraping
I, [2018-08-22 13:08:33 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Info: visits: requests: 2, responses: 2
D, [2018-08-22 13:08:33 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: Browser: driver.current_memory: 212542
D, [2018-08-22 13:08:33 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: Browser: sleep 4 seconds before request...
I, [2018-08-22 13:08:37 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Browser: started get request to: https://github.com/jaimeiniesta/metainspector

...

I, [2018-08-22 13:23:07 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Browser: started get request to: https://github.com/preston/idclight
I, [2018-08-22 13:23:08 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Browser: finished get request to: https://github.com/preston/idclight
I, [2018-08-22 13:23:08 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Info: visits: requests: 140, responses: 140
D, [2018-08-22 13:23:08 +0400#15477] [M: 47377500980720] DEBUG -- github_spider: Browser: driver.current_memory: 204198
I, [2018-08-22 13:23:08 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Browser: driver selenium_chrome has been destroyed

I, [2018-08-22 13:23:08 +0400#15477] [M: 47377500980720]  INFO -- github_spider: Spider: stopped: {:spider_name=>"github_spider", :status=>:completed, :environment=>"development", :start_time=>2018-08-22 13:08:03 +0400, :stop_time=>2018-08-22 13:23:08 +0400, :running_time=>"15m, 5s", :visits=>{:requests=>140, :responses=>140}, :error=>nil}
```
</details>

<details/>
  <summary>results.json</summary>

```json
[
  {
    "owner": "lorien",
    "repo_name": "awesome-web-scraping",
    "repo_url": "https://github.com/lorien/awesome-web-scraping",
    "description": "List of libraries, tools and APIs for web scraping and data processing.",
    "tags": [
      "awesome",
      "awesome-list",
      "web-scraping",
      "data-processing",
      "python",
      "javascript",
      "php",
      "ruby"
    ],
    "watch_count": "159",
    "star_count": "2,423",
    "fork_count": "358",
    "last_commit": "4 days ago",
    "position": 1
  },

  ...

  {
    "owner": "preston",
    "repo_name": "idclight",
    "repo_url": "https://github.com/preston/idclight",
    "description": "A Ruby gem for accessing the freely available IDClight (IDConverter Light) web service, which convert between different types of gene IDs such as Hugo and Entrez. Queries are screen scraped from http://idclight.bioinfo.cnio.es.",
    "tags": [

    ],
    "watch_count": "6",
    "star_count": "1",
    "fork_count": "0",
    "last_commit": "on Apr 12, 2012",
    "position": 127
  }
]
```
</details><br>

Okay, that was easy. How about javascript rendered websites with dynamic HTML? Lets scrape a page with infinite scroll:

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
        logger.info "> Continue scrolling, current count is #{count}..."
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
I, [2018-08-22 13:32:57 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: Spider: started: infinite_scroll_spider
D, [2018-08-22 13:32:57 +0400#23356] [M: 47375890851320] DEBUG -- infinite_scroll_spider: BrowserBuilder (selenium_chrome): created browser instance
D, [2018-08-22 13:32:57 +0400#23356] [M: 47375890851320] DEBUG -- infinite_scroll_spider: BrowserBuilder (selenium_chrome): enabled native headless_mode
I, [2018-08-22 13:32:57 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: Browser: started get request to: https://infinite-scroll.com/demo/full-page/
I, [2018-08-22 13:33:03 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: Browser: finished get request to: https://infinite-scroll.com/demo/full-page/
I, [2018-08-22 13:33:03 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: Info: visits: requests: 1, responses: 1
D, [2018-08-22 13:33:03 +0400#23356] [M: 47375890851320] DEBUG -- infinite_scroll_spider: Browser: driver.current_memory: 95463
I, [2018-08-22 13:33:05 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: > Continue scrolling, current count is 5...
I, [2018-08-22 13:33:18 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: > Continue scrolling, current count is 9...
I, [2018-08-22 13:33:20 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: > Continue scrolling, current count is 11...
I, [2018-08-22 13:33:26 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: > Continue scrolling, current count is 13...
I, [2018-08-22 13:33:28 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: > Continue scrolling, current count is 15...
I, [2018-08-22 13:33:30 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: > Pagination is done
I, [2018-08-22 13:33:30 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: > All posts from page: 1a - Infinite Scroll full page demo; 1b - RGB Schemes logo in Computer Arts; 2a - RGB Schemes logo; 2b - Masonry gets horizontalOrder; 2c - Every vector 2016; 3a - Logo Pizza delivered; 3b - Some CodePens; 3c - 365daysofmusic.com; 3d - Holograms; 4a - Huebee: 1-click color picker; 4b - Word is Flickity is good; Flickity v2 released: groupCells, adaptiveHeight, parallax; New tech gets chatter; Isotope v3 released: stagger in, IE8 out; Packery v2 released
I, [2018-08-22 13:33:30 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: Browser: driver selenium_chrome has been destroyed
I, [2018-08-22 13:33:30 +0400#23356] [M: 47375890851320]  INFO -- infinite_scroll_spider: Spider: stopped: {:spider_name=>"infinite_scroll_spider", :status=>:completed, :environment=>"development", :start_time=>2018-08-22 13:32:57 +0400, :stop_time=>2018-08-22 13:33:30 +0400, :running_time=>"33s", :visits=>{:requests=>1, :responses=>1}, :error=>nil}

```
</details><br>


## Features
* Scrape javascript rendered websites out of box
* Supported engines: [Headless Chrome](https://developers.google.com/web/updates/2017/04/headless-chrome), [Headless Firefox](https://developer.mozilla.org/en-US/docs/Mozilla/Firefox/Headless_mode), [PhantomJS](https://github.com/ariya/phantomjs) or simple HTTP requests ([mechanize](https://github.com/sparklemotion/mechanize) gem)
* Write spider code once, and use it with any supported engine later
* All the power of [Capybara](https://github.com/teamcapybara/capybara): use methods like `click_on`, `fill_in`, `select`, `choose`, `set`, `go_back`, etc. to interact with web pages
* Rich [configuration](#spider-config): **set default headers, cookies, delay between requests, enable proxy/user-agents rotation**
* Built-in helpers to make scraping easy, like [save_to](#save_to-helper) (save items to JSON, JSON lines, or CSV formats) or [unique?](#skip-duplicates-unique-helper) to skip duplicates
* Automatically [handle requests errors](#handle-request-errors)
* Automatically restart browsers when reaching memory limit [**(memory control)**](#spider-config) or requests limit
* Easily [schedule spiders](#schedule-spiders-using-cron) within cron using [Whenever](https://github.com/javan/whenever) (no need to know cron syntax)
* [Parallel scraping](#parallel-crawling-using-in_parallel) using simple method `in_parallel`
* **Two modes:** use single file for a simple spider, or [generate](#project-mode) Scrapy-like **project**
* Convenient development mode with [console](#interactive-console), colorized logger and debugger ([Pry](https://github.com/pry/pry), [Byebug](https://github.com/deivid-rodriguez/byebug))
* Automated [server environment setup](#setup) (for ubuntu 18.04) and [deploy](#deploy) using commands `kimurai setup` and `kimurai deploy` ([Ansible](https://github.com/ansible/ansible) under the hood)
* Command-line [runner](#runner) to run all project spiders one by one or in parallel

## Table of Contents
* [Kimurai](#kimurai)
  * [Features](#features)
  * [Table of Contents](#table-of-contents)
  * [Installation](#installation)
  * [Getting to Know](#getting-to-know)
    * [Interactive console](#interactive-console)
    * [Available engines](#available-engines)
    * [Minimum required spider structure](#minimum-required-spider-structure)
    * [Method arguments response, url and data](#method-arguments-response-url-and-data)
    * [browser object](#browser-object)
    * [request_to method](#request_to-method)
    * [save_to helper](#save_to-helper)
    * [Skip duplicates](#skip-duplicates)
      * [Automatically skip all duplicated requests urls](#automatically-skip-all-duplicated-requests-urls)
      * [Storage object](#storage-object)
    * [Handle request errors](#handle-request-errors)
      * [skip_request_errors](#skip_request_errors)
      * [retry_request_errors](#retry_request_errors)
    * [Logging custom events](#logging-custom-events)
    * [open_spider and close_spider callbacks](#open_spider-and-close_spider-callbacks)
    * [KIMURAI_ENV](#kimurai_env)
    * [Parallel crawling using in_parallel](#parallel-crawling-using-in_parallel)
    * [Active Support included](#active-support-included)
    * [Schedule spiders using Cron](#schedule-spiders-using-cron)
    * [Configuration options](#configuration-options)
    * [Using Kimurai inside existing Ruby application](#using-kimurai-inside-existing-ruby-application)
      * [crawl! method](#crawl-method)
      * [parse! method](#parsemethod_name-url-method)
      * [Kimurai.list and Kimurai.find_by_name](#kimurailist-and-kimuraifind_by_name)
    * [Automated sever setup and deployment](#automated-sever-setup-and-deployment)
      * [Setup](#setup)
      * [Deploy](#deploy)
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
Kimurai requires Ruby version `>= 2.5.0`. Supported platforms: `Linux` and `Mac OS X`.

1) If your system doesn't have appropriate Ruby version, install it:

<details/>
  <summary>Ubuntu 18.04</summary>

```bash
# Install required packages for ruby-build
sudo apt update
sudo apt install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libreadline6-dev libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev

# Install rbenv and ruby-build
cd && git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

# Install latest Ruby
rbenv install 2.5.3
rbenv global 2.5.3

gem install bundler
```
</details>

<details/>
  <summary>Mac OS X</summary>

```bash
# Install homebrew if you don't have it https://brew.sh/
# Install rbenv and ruby-build:
brew install rbenv ruby-build

# Add rbenv to bash so that it loads every time you open a terminal
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile

# Install latest Ruby
rbenv install 2.5.3
rbenv global 2.5.3

gem install bundler
```
</details>

2) Install Kimurai gem: `$ gem install kimurai`

3) Install browsers with webdrivers:

<details/>
  <summary>Ubuntu 18.04</summary>

Note: for Ubuntu 16.04-18.04 there is available automatic installation using `setup` command:
```bash
$ kimurai setup localhost --local --ask-sudo
```
It works using [Ansible](https://github.com/ansible/ansible) so you need to install it first: `$ sudo apt install ansible`. You can check using playbooks [here](lib/kimurai/automation).

If you chose automatic installation, you can skip following and go to "Getting To Know" part. In case if you want to install everything manually:

```bash
# Install basic tools
sudo apt install -q -y unzip wget tar openssl

# Install xvfb (for virtual_display headless mode, in additional to native)
sudo apt install -q -y xvfb

# Install chromium-browser and firefox
sudo apt install -q -y chromium-browser firefox

# Instal chromedriver (2.44 version)
# All versions located here https://sites.google.com/a/chromium.org/chromedriver/downloads
cd /tmp && wget https://chromedriver.storage.googleapis.com/2.44/chromedriver_linux64.zip
sudo unzip chromedriver_linux64.zip -d /usr/local/bin
rm -f chromedriver_linux64.zip

# Install geckodriver (0.23.0 version)
# All versions located here https://github.com/mozilla/geckodriver/releases/
cd /tmp && wget https://github.com/mozilla/geckodriver/releases/download/v0.23.0/geckodriver-v0.23.0-linux64.tar.gz
sudo tar -xvzf geckodriver-v0.23.0-linux64.tar.gz -C /usr/local/bin
rm -f geckodriver-v0.23.0-linux64.tar.gz

# Install PhantomJS (2.1.1)
# All versions located here http://phantomjs.org/download.html
sudo apt install -q -y chrpath libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev
cd /tmp && wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
tar -xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2
sudo mv phantomjs-2.1.1-linux-x86_64 /usr/local/lib
sudo ln -s /usr/local/lib/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin
rm -f phantomjs-2.1.1-linux-x86_64.tar.bz2
```

</details>

<details/>
  <summary>Mac OS X</summary>

```bash
# Install chrome and firefox
brew cask install google-chrome firefox

# Install chromedriver (latest)
brew cask install chromedriver

# Install geckodriver (latest)
brew install geckodriver

# Install PhantomJS (latest)
brew install phantomjs
```
</details><br>

Also, if you want to save scraped items to the database (using [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord), [Sequel](https://github.com/jeremyevans/sequel) or [MongoDB Ruby Driver](https://github.com/mongodb/mongo-ruby-driver)/[Mongoid](https://github.com/mongodb/mongoid)), you need to install database clients/servers:

<details/>
  <summary>Ubuntu 18.04</summary>

SQlite: `$ sudo apt -q -y install libsqlite3-dev sqlite3`.

If you want to connect to a remote database, you don't need database server on a local machine (only client):
```bash
# Install MySQL client
sudo apt -q -y install mysql-client libmysqlclient-dev

# Install Postgres client
sudo apt install -q -y postgresql-client libpq-dev

# Install MongoDB client
sudo apt install -q -y mongodb-clients
```

But if you want to save items to a local database, database server required as well:
```bash
# Install MySQL client and server
sudo apt -q -y install mysql-server mysql-client libmysqlclient-dev

# Install  Postgres client and server
sudo apt install -q -y postgresql postgresql-contrib libpq-dev

# Install MongoDB client and server
# version 4.0 (check here https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/)
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
# for 16.04:
# echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
# for 18.04:
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt update
sudo apt install -q -y mongodb-org
sudo service mongod start
```
</details>

<details/>
  <summary>Mac OS X</summary>

SQlite: `$ brew install sqlite3`

```bash
# Install MySQL client and server
brew install mysql
# Start server if you need it: brew services start mysql

# Install Postgres client and server
brew install postgresql
# Start server if you need it: brew services start postgresql

# Install MongoDB client and server
brew install mongodb
# Start server if you need it: brew services start mongodb
```
</details>


## Getting to Know
### Interactive console
Before you get to know all Kimurai features, there is `$ kimurai console` command which is an interactive console where you can try and debug your scraping code very quickly, without having to run any spider (yes, it's like [Scrapy shell](https://doc.scrapy.org/en/latest/topics/shell.html#topics-shell)).

```bash
$ kimurai console --engine selenium_chrome --url https://github.com/vifreefly/kimuraframework
```

<details/>
  <summary>Show output</summary>

```
$ kimurai console --engine selenium_chrome --url https://github.com/vifreefly/kimuraframework

D, [2018-08-22 13:42:32 +0400#26079] [M: 47461994677760] DEBUG -- : BrowserBuilder (selenium_chrome): created browser instance
D, [2018-08-22 13:42:32 +0400#26079] [M: 47461994677760] DEBUG -- : BrowserBuilder (selenium_chrome): enabled native headless_mode
I, [2018-08-22 13:42:32 +0400#26079] [M: 47461994677760]  INFO -- : Browser: started get request to: https://github.com/vifreefly/kimuraframework
I, [2018-08-22 13:42:35 +0400#26079] [M: 47461994677760]  INFO -- : Browser: finished get request to: https://github.com/vifreefly/kimuraframework
D, [2018-08-22 13:42:35 +0400#26079] [M: 47461994677760] DEBUG -- : Browser: driver.current_memory: 201701

From: /home/victor/code/kimurai/lib/kimurai/base.rb @ line 189 Kimurai::Base#console:

    188: def console(response = nil, url: nil, data: {})
 => 189:   binding.pry
    190: end

[1] pry(#<Kimurai::Base>)> response.xpath("//title").text
=> "GitHub - vifreefly/kimuraframework: Modern web scraping framework written in Ruby which works out of box with Headless Chromium/Firefox, PhantomJS, or simple HTTP requests and allows to scrape and interact with JavaScript rendered websites"

[2] pry(#<Kimurai::Base>)> ls
Kimurai::Base#methods: browser  console  logger  request_to  save_to  unique?
instance variables: @browser  @config  @engine  @logger  @pipelines
locals: _  __  _dir_  _ex_  _file_  _in_  _out_  _pry_  data  response  url

[3] pry(#<Kimurai::Base>)> ls response
Nokogiri::XML::PP::Node#methods: inspect  pretty_print
Nokogiri::XML::Searchable#methods: %  /  at  at_css  at_xpath  css  search  xpath
Enumerable#methods:
  all?         collect         drop        each_with_index   find_all    grep_v    lazy    member?    none?      reject        slice_when  take_while  without
  any?         collect_concat  drop_while  each_with_object  find_index  group_by  many?   min        one?       reverse_each  sort        to_a        zip
  as_json      count           each_cons   entries           first       include?  map     min_by     partition  select        sort_by     to_h
  chunk        cycle           each_entry  exclude?          flat_map    index_by  max     minmax     pluck      slice_after   sum         to_set
  chunk_while  detect          each_slice  find              grep        inject    max_by  minmax_by  reduce     slice_before  take        uniq
Nokogiri::XML::Node#methods:
  <=>                   append_class       classes                 document?             has_attribute?      matches?          node_name=        processing_instruction?  to_str
  ==                    attr               comment?                each                  html?               name=             node_type         read_only?               to_xhtml
  >                     attribute          content                 elem?                 inner_html          namespace=        parent=           remove                   traverse
  []                    attribute_nodes    content=                element?              inner_html=         namespace_scopes  parse             remove_attribute         unlink
  []=                   attribute_with_ns  create_external_subset  element_children      inner_text          namespaced_key?   path              remove_class             values
  accept                before             create_internal_subset  elements              internal_subset     native_content=   pointer_id        replace                  write_html_to
  add_class             blank?             css_path                encode_special_chars  key?                next              prepend_child     set_attribute            write_to
  add_next_sibling      cdata?             decorate!               external_subset       keys                next=             previous          text                     write_xhtml_to
  add_previous_sibling  child              delete                  first_element_child   lang                next_element      previous=         text?                    write_xml_to
  after                 children           description             fragment?             lang=               next_sibling      previous_element  to_html                  xml?
  ancestors             children=          do_xinclude             get_attribute         last_element_child  node_name         previous_sibling  to_s
Nokogiri::XML::Document#methods:
  <<         canonicalize  collect_namespaces  create_comment  create_entity     decorate    document  encoding   errors   name        remove_namespaces!  root=  to_java  url       version
  add_child  clone         create_cdata        create_element  create_text_node  decorators  dup       encoding=  errors=  namespaces  root                slop!  to_xml   validate
Nokogiri::HTML::Document#methods: fragment  meta_encoding  meta_encoding=  serialize  title  title=  type
instance variables: @decorators  @errors  @node_cache

[4] pry(#<Kimurai::Base>)> exit
I, [2018-08-22 13:43:47 +0400#26079] [M: 47461994677760]  INFO -- : Browser: driver selenium_chrome has been destroyed
$
```
</details><br>

CLI options:
* `--engine` (optional) [engine](#available-drivers) to use. Default is `mechanize`
* `--url` (optional) url to process. If url omitted, `response` and `url` objects inside the console will be `nil` (use [browser](#browser-object) object to navigate to any webpage).

### Available engines
Kimurai has support for following engines and mostly can switch between them without need to rewrite any code:

* `:mechanize` - [pure Ruby fake http browser](https://github.com/sparklemotion/mechanize). Mechanize can't render javascript and don't know what DOM is it. It only can parse original HTML code of a page. Because of it, mechanize much faster, takes much less memory and in general much more stable than any real browser. Use mechanize if you can do it, and the website doesn't use javascript to render any meaningful parts of its structure. Still, because mechanize trying to mimic a real browser, it supports almost all Capybara's [methods to interact with a web page](http://cheatrags.com/capybara) (filling forms, clicking buttons, checkboxes, etc).
* `:poltergeist_phantomjs` - [PhantomJS headless browser](https://github.com/ariya/phantomjs), can render javascript. In general, PhantomJS still faster than Headless Chrome (and Headless Firefox). PhantomJS has memory leakage, but Kimurai has [memory control feature](#crawler-config) so you shouldn't consider it as a problem. Also, some websites can recognize PhantomJS and block access to them. Like mechanize (and unlike selenium engines) `:poltergeist_phantomjs` can freely rotate proxies and change headers _on the fly_ (see [config section](#all-available-config-options)).
* `:selenium_chrome` Chrome in headless mode driven by selenium. Modern headless browser solution with proper javascript rendering.
* `:selenium_firefox` Firefox in headless mode driven by selenium. Usually takes more memory than other drivers, but sometimes can be useful.

**Tip:** add `HEADLESS=false` ENV variable before command (`$ HEADLESS=false ruby spider.rb`) to run browser in normal (not headless) mode and see it's window (only for selenium-like engines). It works for [console](#interactive-console) command as well.


### Minimum required spider structure
> You can manually create a spider file, or use generator instead: `$ kimurai generate spider simple_spider`

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
* `@name` name of a spider. You can omit name if use single-file spider
* `@engine` engine for a spider
* `@start_urls` array of start urls to process one by one inside `parse` method
* Method `parse` is the start method, should be always present in spider class


### Method arguments `response`, `url` and `data`

```ruby
def parse(response, url:, data: {})
end
```

* `response` ([Nokogiri::HTML::Document](https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/HTML/Document) object) Contains parsed HTML code of a processed webpage
* `url` (String) url of a processed webpage
* `data` (Hash) uses to pass data between requests

<details/>
  <summary><strong>Example how to use <code>data</code></strong></summary>

Imagine that there is a product page which doesn't contain product category. Category name present only on category page with pagination. This is the case where we can use `data` to pass category name from `parse` to `parse_product` method:

```ruby
class ProductsSpider < Kimurai::Base
  @engine = :selenium_chrome
  @start_urls = ["https://example-shop.com/example-product-category"]

  def parse(response, url:, data: {})
    category_name = response.xpath("//path/to/category/name").text
    response.xpath("//path/to/products/urls").each do |product_url|
      # Merge category_name with current data hash and pass it next to parse_product method
      request_to(:parse_product, url: product_url[:href], data: data.merge(category_name: category_name))
    end

    # ...
  end

  def parse_product(response, url:, data: {})
    item = {}
    # Assign item's category_name from data[:category_name]
    item[:category_name] = data[:category_name]

    # ...
  end
end

```
</details><br>

**You can query `response` using [XPath or CSS selectors](https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Searchable)**. Check Nokogiri tutorials to understand how to work with `response`:
* [Parsing HTML with Nokogiri](http://ruby.bastardsbook.com/chapters/html-parsing/) - ruby.bastardsbook.com
* [HOWTO parse HTML with Ruby & Nokogiri](https://readysteadycode.com/howto-parse-html-with-ruby-and-nokogiri) - readysteadycode.com
* [Class: Nokogiri::HTML::Document](https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/HTML/Document) (documentation) - rubydoc.info


### `browser` object

From any spider instance method there is available `browser` object, which is [Capybara::Session](https://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session) object and uses to process requests and get page response (`current_response` method). Usually you don't need to touch it directly, because there is `response` (see above) which contains page response after it was loaded.

But if you need to interact with a page (like filling form fields, clicking elements, checkboxes, etc) `browser` is ready for you:

```ruby
class GoogleSpider < Kimurai::Base
  @name = "google_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://www.google.com/"]

  def parse(response, url:, data: {})
    browser.fill_in "q", with: "Kimurai web scraping framework"
    browser.click_button "Google Search"

    # Update response to current response after interaction with a browser
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
* [UI Testing with RSpec and Capybara [cheat sheet]](http://cheatrags.com/capybara) - cheatrags.com
* [Capybara Cheatsheet PDF](https://thoughtbot.com/upcase/test-driven-rails-resources/capybara.pdf) - thoughtbot.com
* [Class: Capybara::Session](https://www.rubydoc.info/github/jnicklas/capybara/Capybara/Session) (documentation) - rubydoc.info

### `request_to` method

For making requests to a particular method there is `request_to`. It requires minimum two arguments: `:method_name` and `url:`. An optional argument is `data:` (see above what for is it). Example:

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

Under the hood `request_to` simply call [#visit](https://www.rubydoc.info/github/jnicklas/capybara/Capybara%2FSession:visit) (`browser.visit(url)`) and then required method with arguments:

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

`request_to` just makes things simpler, and without it we could do something like:

<details/>
  <summary>Check the code</summary>

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

Sometimes all that you need is to simply save scraped data to a file format, like JSON or CSV. You can use `save_to` for it:

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

    # Add each new item to the `scraped_products.json` file:
    save_to "scraped_products.json", item, format: :json
  end
end
```

Supported formats:
* `:json` JSON
* `:pretty_json` "pretty" JSON (`JSON.pretty_generate`)
* `:jsonlines` [JSON Lines](http://jsonlines.org/)
* `:csv` CSV

Note: `save_to` requires data (item to save) to be a `Hash`.

By default `save_to` add position key to an item hash. You can disable it with `position: false`: `save_to "scraped_products.json", item, format: :json, position: false`.

**How helper works:**

Until spider stops, each new item will be appended to a file. At the next run, helper will clear the content of a file first, and then start again appending items to it.

> If you don't want file to be cleared before each run, add option `append: true`: `save_to "scraped_products.json", item, format: :json, append: true`

### Skip duplicates

It's pretty common when websites have duplicated pages. For example when an e-commerce shop has the same products in different categories. To skip duplicates, there is simple `unique?` helper:

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

  # Or/and check products for uniqueness using product sku inside of parse_product:
  def parse_product(response, url:, data: {})
    item = {}
    item[:sku] = response.xpath("//product/sku/path").text.strip.upcase
    # Don't save product and return from method if there is already saved item with the same sku:
    return unless unique?(:sku, item[:sku])

    # ...
    save_to "results.json", item, format: :json
  end
end
```

`unique?` helper works pretty simple:

```ruby
# Check string "http://example.com" in scope `url` for a first time:
unique?(:url, "http://example.com")
# => true

# Try again:
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

#### Automatically skip all duplicated requests urls

It is possible to automatically skip all already visited urls while calling `request_to` method, using [@config](#all-available-config-options) option `skip_duplicate_requests: true`. With this option, all already visited urls will be automatically skipped. Also check the [@config](#all-available-config-options) for an additional options of this setting.

#### `storage` object

`unique?` method it's just an alias for `storage#unique?`. Storage has several methods:

* `#all` - display storage hash where keys are existing scopes.
* `#include?(scope, value)` - return `true` if value in the scope exists, and `false` if not
* `#add(scope, value)` - add value to the scope
* `#unique?(scope, value)` - method already described above, will return `false` if value in the scope exists, or return `true` + add value to the scope if value in the scope not exists.
* `#clear!` - reset the whole storage by deleting all values from all scopes.


### Handle request errors
It is quite common that some pages of crawling website can return different response code than `200 ok`. In such cases, method `request_to` (or `browser.visit`) can raise an exception. Kimurai provides `skip_request_errors` and `retry_request_errors` [config](#spider-config) options to handle such errors:

#### skip_request_errors
You can automatically skip some of errors while requesting a page using `skip_request_errors` [config](#spider-config) option. If raised error matches one of the errors in the list, then this error will be caught, and request will be skipped. It is a good idea to skip errors like NotFound(404), etc.

Format for the option: array where elements are error classes or/and hashes. You can use _hash_ format for more flexibility:

```
@config = {
  skip_request_errors: [{ error: RuntimeError, message: "404 => Net::HTTPNotFound" }]
}
```
In this case, provided `message:` will be compared with a full error message using `String#include?`. Also you can use regex instead: `{ error: RuntimeError, message: /404|403/ }`.

#### retry_request_errors
You can automatically retry some of errors with a few attempts while requesting a page using `retry_request_errors` [config](#spider-config) option. If raised error matches one of the errors in the list, then this error will be caught and the request will be processed again within a delay.

There are 3 attempts: first: delay _15 sec_, second: delay _30 sec_, third: delay _45 sec_. If after 3 attempts there is still an exception, then the exception will be raised. It is a good idea to try to retry errros like `ReadTimeout`, `HTTPBadGateway`, etc.

Format for the option: same like for `skip_request_errors` option.

If you would like to skip (not raise) error after all retries gone, you can specify `skip_on_failure: true` option:

```ruby
@config = {
  retry_request_errors: [{ error: RuntimeError, skip_on_failure: true }]
}
```

### Logging custom events

It is possible to save custom messages to the [run_info](#open_spider-and-close_spider-callbacks) hash using `add_event('Some message')` method. This feature helps you to keep track on important things which happened during crawling without checking the whole spider log (in case if you're logging these messages using `logger`). Example:

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

You can define `.open_spider` and `.close_spider` callbacks (class methods) to perform some action before spider started or after spider has been stopped:

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

Inside `open_spider` and `close_spider` class methods there is available `run_info` method which contains useful information about spider state:

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

Inside `close_spider`, `run_info` will be updated:

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

`run_info[:status]` helps to determine if spider was finished successfully or failed (possible values: `:completed`, `:failed`):

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

**Usage example:** if spider finished successfully, send JSON file with scraped items to a remote FTP location, otherwise (if spider failed), skip incompleted results and send email/notification to slack about it:

<details/>
  <summary>Example</summary>

Also you can use additional methods `completed?` or `failed?`

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
Kimurai has environments, default is `development`. To provide custom environment pass `KIMURAI_ENV` ENV variable before command: `$ KIMURAI_ENV=production ruby spider.rb`. To access current environment there is `Kimurai.env` method.

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
Kimurai can process web pages concurrently in one single line: `in_parallel(:parse_product, urls, threads: 3)`, where `:parse_product` is a method to process, `urls` is array of urls to crawl and `threads:` is a number of threads:

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

    # Walk through pagination and collect products urls:
    urls = []
    loop do
      response = browser.current_response
      response.xpath("//li//a[contains(@class, 's-access-detail-page')]").each do |a|
        urls << a[:href].sub(/ref=.+/, "")
      end

      browser.find(:xpath, "//a[@id='pagnNextLink']", wait: 1).click rescue break
    end

    # Process all collected urls concurrently within 3 threads:
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
I, [2018-08-22 14:48:37 +0400#13033] [M: 46982297486840]  INFO -- amazon_spider: Spider: started: amazon_spider
D, [2018-08-22 14:48:37 +0400#13033] [M: 46982297486840] DEBUG -- amazon_spider: BrowserBuilder (mechanize): created browser instance
I, [2018-08-22 14:48:37 +0400#13033] [M: 46982297486840]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/
I, [2018-08-22 14:48:38 +0400#13033] [M: 46982297486840]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/
I, [2018-08-22 14:48:38 +0400#13033] [M: 46982297486840]  INFO -- amazon_spider: Info: visits: requests: 1, responses: 1

I, [2018-08-22 14:48:43 +0400#13033] [M: 46982297486840]  INFO -- amazon_spider: Spider: in_parallel: starting processing 52 urls within 3 threads
D, [2018-08-22 14:48:43 +0400#13033] [C: 46982320219020] DEBUG -- amazon_spider: BrowserBuilder (mechanize): created browser instance
I, [2018-08-22 14:48:43 +0400#13033] [C: 46982320219020]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Practical-Web-Scraping-Data-Science/dp/1484235819/
D, [2018-08-22 14:48:44 +0400#13033] [C: 46982320189640] DEBUG -- amazon_spider: BrowserBuilder (mechanize): created browser instance
I, [2018-08-22 14:48:44 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Python-Web-Scraping-Cookbook-scraping/dp/1787285219/
D, [2018-08-22 14:48:44 +0400#13033] [C: 46982319187320] DEBUG -- amazon_spider: BrowserBuilder (mechanize): created browser instance
I, [2018-08-22 14:48:44 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Scraping-Python-Community-Experience-Distilled/dp/1782164367/
I, [2018-08-22 14:48:45 +0400#13033] [C: 46982320219020]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Practical-Web-Scraping-Data-Science/dp/1484235819/
I, [2018-08-22 14:48:45 +0400#13033] [C: 46982320219020]  INFO -- amazon_spider: Info: visits: requests: 4, responses: 2
I, [2018-08-22 14:48:45 +0400#13033] [C: 46982320219020]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Web-Scraping-Python-Collecting-Modern/dp/1491910291/
I, [2018-08-22 14:48:46 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Python-Web-Scraping-Cookbook-scraping/dp/1787285219/
I, [2018-08-22 14:48:46 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Info: visits: requests: 5, responses: 3
I, [2018-08-22 14:48:46 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Web-Scraping-Python-Collecting-Modern/dp/1491985577/
I, [2018-08-22 14:48:46 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Scraping-Python-Community-Experience-Distilled/dp/1782164367/
I, [2018-08-22 14:48:46 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Info: visits: requests: 6, responses: 4
I, [2018-08-22 14:48:46 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Web-Scraping-Excel-Effective-Scrapes-ebook/dp/B01CMMJGZ8/

...

I, [2018-08-22 14:49:10 +0400#13033] [C: 46982320219020]  INFO -- amazon_spider: Info: visits: requests: 51, responses: 49
I, [2018-08-22 14:49:10 +0400#13033] [C: 46982320219020]  INFO -- amazon_spider: Browser: driver mechanize has been destroyed
I, [2018-08-22 14:49:11 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Scraping-Ice-Life-Bill-Rayburn-ebook/dp/B00C0NF1L8/
I, [2018-08-22 14:49:11 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Info: visits: requests: 51, responses: 50
I, [2018-08-22 14:49:11 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Instant-Scraping-Jacob-Ward-2013-07-26/dp/B01FJ1G3G4/
I, [2018-08-22 14:49:11 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Php-architects-Guide-Scraping-Author/dp/B010DTKYY4/
I, [2018-08-22 14:49:11 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Info: visits: requests: 52, responses: 51
I, [2018-08-22 14:49:11 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Browser: started get request to: https://www.amazon.com/Ship-Tracking-Maritime-Domain-Awareness/dp/B001J5MTOK/
I, [2018-08-22 14:49:12 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Instant-Scraping-Jacob-Ward-2013-07-26/dp/B01FJ1G3G4/
I, [2018-08-22 14:49:12 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Info: visits: requests: 53, responses: 52
I, [2018-08-22 14:49:12 +0400#13033] [C: 46982320189640]  INFO -- amazon_spider: Browser: driver mechanize has been destroyed
I, [2018-08-22 14:49:12 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Browser: finished get request to: https://www.amazon.com/Ship-Tracking-Maritime-Domain-Awareness/dp/B001J5MTOK/
I, [2018-08-22 14:49:12 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Info: visits: requests: 53, responses: 53
I, [2018-08-22 14:49:12 +0400#13033] [C: 46982319187320]  INFO -- amazon_spider: Browser: driver mechanize has been destroyed

I, [2018-08-22 14:49:12 +0400#13033] [M: 46982297486840]  INFO -- amazon_spider: Spider: in_parallel: stopped processing 52 urls within 3 threads, total time: 29s
I, [2018-08-22 14:49:12 +0400#13033] [M: 46982297486840]  INFO -- amazon_spider: Browser: driver mechanize has been destroyed

I, [2018-08-22 14:49:12 +0400#13033] [M: 46982297486840]  INFO -- amazon_spider: Spider: stopped: {:spider_name=>"amazon_spider", :status=>:completed, :environment=>"development", :start_time=>2018-08-22 14:48:37 +0400, :stop_time=>2018-08-22 14:49:12 +0400, :running_time=>"35s", :visits=>{:requests=>53, :responses=>53}, :error=>nil}

```
</details>

<details/>
  <summary>books.json</summary>

```json
[
  {
    "title": "Web Scraping with Python: Collecting More Data from the Modern Web2nd Edition",
    "url": "https://www.amazon.com/Web-Scraping-Python-Collecting-Modern/dp/1491985577/",
    "price": "$26.94",
    "publisher": "O'Reilly Media; 2 edition (April 14, 2018)",
    "position": 1
  },
  {
    "title": "Python Web Scraping Cookbook: Over 90 proven recipes to get you scraping with Python, micro services, Docker and AWS",
    "url": "https://www.amazon.com/Python-Web-Scraping-Cookbook-scraping/dp/1787285219/",
    "price": "$39.99",
    "publisher": "Packt Publishing - ebooks Account (February 9, 2018)",
    "position": 2
  },
  {
    "title": "Web Scraping with Python: Collecting Data from the Modern Web1st Edition",
    "url": "https://www.amazon.com/Web-Scraping-Python-Collecting-Modern/dp/1491910291/",
    "price": "$15.75",
    "publisher": "O'Reilly Media; 1 edition (July 24, 2015)",
    "position": 3
  },

  ...

  {
    "title": "Instant Web Scraping with Java by Ryan Mitchell (2013-08-26)",
    "url": "https://www.amazon.com/Instant-Scraping-Java-Mitchell-2013-08-26/dp/B01FEM76X2/",
    "price": "$35.82",
    "publisher": "Packt Publishing (2013-08-26) (1896)",
    "position": 52
  }
]
```
</details><br>

> Note that [save_to](#save_to-helper) and [unique?](#skip-duplicates-unique-helper) helpers are thread-safe (protected by [Mutex](https://ruby-doc.org/core-2.5.1/Mutex.html)) and can be freely used inside threads.

`in_parallel` can take additional options:
* `data:` pass with urls custom data hash: `in_parallel(:method, urls, threads: 3, data: { category: "Scraping" })`
* `delay:` set delay between requests: `in_parallel(:method, urls, threads: 3, delay: 2)`. Delay can be `Integer`, `Float` or `Range` (`2..5`). In case of a Range, delay number will be chosen randomly for each request: `rand (2..5) # => 3`
* `engine:` set custom engine than a default one: `in_parallel(:method, urls, threads: 3, engine: :poltergeist_phantomjs)`
* `config:` pass custom options to config (see [config section](#crawler-config))

### Active Support included

You can use all the power of familiar [Rails core-ext methods](https://guides.rubyonrails.org/active_support_core_extensions.html#loading-all-core-extensions) for scraping inside Kimurai. Especially take a look at [squish](https://apidock.com/rails/String/squish), [truncate_words](https://apidock.com/rails/String/truncate_words), [titleize](https://apidock.com/rails/String/titleize), [remove](https://apidock.com/rails/String/remove), [present?](https://guides.rubyonrails.org/active_support_core_extensions.html#blank-questionmark-and-present-questionmark) and [presence](https://guides.rubyonrails.org/active_support_core_extensions.html#presence).

### Schedule spiders using Cron

1) Inside spider directory generate [Whenever](https://github.com/javan/whenever) config: `$ kimurai generate schedule`.

<details/>
  <summary><code>schedule.rb</code></summary>

```ruby
### Settings ###
require 'tzinfo'

# Export current PATH to the cron
env :PATH, ENV["PATH"]

# Use 24 hour format when using `at:` option
set :chronic_options, hours24: true

# Use local_to_utc helper to setup execution time using your local timezone instead
# of server's timezone (which is probably and should be UTC, to check run `$ timedatectl`).
# Also maybe you'll want to set same timezone in kimurai as well (use `Kimurai.configuration.time_zone =` for that),
# to have spiders logs in a specific time zone format.
# Example usage of helper:
# every 1.day, at: local_to_utc("7:00", zone: "Europe/Moscow") do
#   crawl "google_spider.com", output: "log/google_spider.com.log"
# end
def local_to_utc(time_string, zone:)
  TZInfo::Timezone.get(zone).local_to_utc(Time.parse(time_string))
end

# Note: by default Whenever exports cron commands with :environment == "production".
# Note: Whenever can only append log data to a log file (>>). If you want
# to overwrite (>) log file before each run, pass lambda:
# crawl "google_spider.com", output: -> { "> log/google_spider.com.log 2>&1" }

# Project job types
job_type :crawl,  "cd :path && KIMURAI_ENV=:environment bundle exec kimurai crawl :task :output"
job_type :runner, "cd :path && KIMURAI_ENV=:environment bundle exec kimurai runner --jobs :task :output"

# Single file job type
job_type :single, "cd :path && KIMURAI_ENV=:environment ruby :task :output"
# Single with bundle exec
job_type :single_bundle, "cd :path && KIMURAI_ENV=:environment bundle exec ruby :task :output"

### Schedule ###
# Usage (check examples here https://github.com/javan/whenever#example-schedulerb-file):
# every 1.day do
  # Example to schedule a single spider in the project:
  # crawl "google_spider.com", output: "log/google_spider.com.log"

  # Example to schedule all spiders in the project using runner. Each spider will write
  # it's own output to the `log/spider_name.log` file (handled by a runner itself).
  # Runner output will be written to log/runner.log file.
  # Argument number it's a count of concurrent jobs:
  # runner 3, output:"log/runner.log"

  # Example to schedule single spider (without project):
  # single "single_spider.rb", output: "single_spider.log"
# end

### How to set a cron schedule ###
# Run: `$ whenever --update-crontab --load-file config/schedule.rb`.
# If you don't have whenever command, install the gem: `$ gem install whenever`.

### How to cancel a schedule ###
# Run: `$ whenever --clear-crontab --load-file config/schedule.rb`.
```
</details><br>

2) Add at the bottom of `schedule.rb` following code:

```ruby
every 1.day, at: "7:00" do
  single "example_spider.rb", output: "example_spider.log"
end
```

3) Run: `$ whenever --update-crontab --load-file schedule.rb`. Done!

You can check Whenever examples [here](https://github.com/javan/whenever#example-schedulerb-file). To cancel schedule, run: `$ whenever --clear-crontab --load-file schedule.rb`.

### Configuration options
You can configure several options using `configure` block:

```ruby
Kimurai.configure do |config|
  # Default logger has colored mode in development.
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

### Using Kimurai inside existing Ruby application

You can integrate Kimurai spiders (which are just Ruby classes) to an existing Ruby application like Rails or Sinatra, and run them using background jobs (for example). Check the following info to understand the running process of spiders:

#### `.crawl!` method

`.crawl!` (class method) performs a _full run_ of a particular spider. This method will return run_info if run was successful, or an exception if something went wrong.

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

You can't `.crawl!` spider in different thread if it still running (because spider instances store some shared data in the `@run_info` class variable while `crawl`ing):

```ruby
2.times do |i|
  Thread.new { p i, ExampleSpider.crawl! }
end # =>

# 1
# false

# 0
# {:spider_name=>"example_spider", :status=>:completed, :environment=>"development", :start_time=>2018-08-22 18:49:22 +0400, :stop_time=>2018-08-22 18:49:23 +0400, :running_time=>0.801, :visits=>{:requests=>1, :responses=>1}, :items=>{:sent=>0, :processed=>0}, :error=>nil}
```

So what if you're don't care about stats and just want to process request to a particular spider method and get the returning value from this method? Use `.parse!` instead:

#### `.parse!(:method_name, url:, config: {})` method

`.parse!` (class method) creates a new spider instance and performs a request to given method with a given url. Value from the method will be returned back:

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
# this is example when you need to override config
ExampleSpider.parse!(:parse, url: "https://example.com/", config: { before_request: { clear_and_set_cookies: true } } )
```

Like `.crawl!`, `.parse!` method takes care of a browser instance and kills it (`browser.destroy_driver!`) before returning the value. Unlike `.crawl!`, `.parse!` method can be called from different threads at the same time:

```ruby
urls = ["https://www.google.com/", "https://www.reddit.com/", "https://en.wikipedia.org/"]

urls.each do |url|
  Thread.new { p ExampleSpider.parse!(:parse, url: url) }
end # =>

# "Google"
# "Wikipedia, the free encyclopedia"
# "reddit: the front page of the internetHotHot"
```

Keep in mind, that [save_to](#save_to-helper) and [unique?](#skip-duplicates) helpers are not thread-safe while using `.parse!` method.

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

# To find a particular spider class by it's name:
Kimurai.find_by_name("reddit_spider")
# => RedditSpider
```


### Automated sever setup and deployment
> **EXPERIMENTAL**

#### Setup
You can automatically setup [required environment](#installation) for Kimurai on the remote server (currently there is only Ubuntu Server 18.04 support) using `$ kimurai setup` command. `setup` will perform installation of: latest Ruby with Rbenv, browsers with webdrivers and in additional databases clients (only clients) for MySQL, Postgres and MongoDB (so you can connect to a remote database from ruby).

> To perform remote server setup, [Ansible](https://github.com/ansible/ansible) is required **on the desktop** machine (to install: Ubuntu: `$ sudo apt install ansible`, Mac OS X: `$ brew install ansible`)

> It's recommended to use regular user to setup the server, not `root`. To create a new user, login to the server `$ ssh root@your_server_ip`, type `$ adduser username` to create a user, and `$ gpasswd -a username sudo` to add new user to a sudo group.

Example:

```bash
$ kimurai setup deploy@123.123.123.123 --ask-sudo --ssh-key-path path/to/private_key
```

CLI options:
* `--ask-sudo` pass this option to ask sudo (user) password for system-wide installation of packages (`apt install`)
* `--ssh-key-path path/to/private_key` authorization on the server using private ssh key. You can omit it if required key already [added to keychain](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#adding-your-ssh-key-to-the-ssh-agent) on your desktop (Ansible uses [SSH agent forwarding](https://developer.github.com/v3/guides/using-ssh-agent-forwarding/))
* `--ask-auth-pass` authorization on the server using user password, alternative option to `--ssh-key-path`.
* `-p port_number` custom port for ssh connection (`-p 2222`)

> You can check setup playbook [here](lib/kimurai/automation/setup.yml)

#### Deploy

After successful `setup` you can deploy a spider to the remote server using `$ kimurai deploy` command. On each deploy there are performing several tasks: 1) pull repo from a remote origin to `~/repo_name` user directory 2) run `bundle install` 3) Update crontab `whenever --update-crontab` (to update spider schedule from schedule.rb file).

Before `deploy` make sure that inside spider directory you have: 1) git repository with remote origin (bitbucket, github, etc.) 2) `Gemfile` 3) schedule.rb inside subfolder `config` (`config/schedule.rb`).

Example:

```bash
$ kimurai deploy deploy@123.123.123.123 --ssh-key-path path/to/private_key --repo-key-path path/to/repo_private_key
```

CLI options: _same like for [setup](#setup) command_ (except `--ask-sudo`), plus
* `--repo-url` provide custom repo url (`--repo-url git@bitbucket.org:username/repo_name.git`), otherwise current `origin/master` will be taken (output from `$ git remote get-url origin`)
* `--repo-key-path` if git repository is private, authorization is required to pull the code on the remote server. Use this option to provide a private repository SSH key. You can omit it if required key already added to keychain on your desktop (same like with `--ssh-key-path` option)

> You can check deploy playbook [here](lib/kimurai/automation/deploy.yml)

## Spider `@config`

Using `@config` you can set several options for a spider, like proxy, user-agent, default cookies/headers, delay between requests, browser **memory control** and so on:

```ruby
class Spider < Kimurai::Base
  USER_AGENTS = ["Chrome", "Firefox", "Safari", "Opera"]
  PROXIES = ["2.3.4.5:8080:http:username:password", "3.4.5.6:3128:http", "1.2.3.4:3000:socks5"]

  @engine = :poltergeist_phantomjs
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
      # Process delay before each request:
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
  # Custom headers, format: hash. Example: { "some header" => "some value", "another header" => "another value" }
  # Works only for :mechanize and :poltergeist_phantomjs engines (Selenium doesn't allow to set/get headers)
  headers: {},

  # Custom User Agent, format: string or lambda.
  # Use lambda if you want to rotate user agents before each run:
  # user_agent: -> { ARRAY_OF_USER_AGENTS.sample }
  # Works for all engines
  user_agent: "Mozilla/5.0 Firefox/61.0",

  # Custom cookies, format: array of hashes.
  # Format for a single cookie: { name: "cookie name", value: "cookie value", domain: ".example.com" }
  # Works for all engines
  cookies: [],

  # Proxy, format: string or lambda. Format of a proxy string: "ip:port:protocol:user:password"
  # `protocol` can be http or socks5. User and password are optional.
  # Use lambda if you want to rotate proxies before each run:
  # proxy: -> { ARRAY_OF_PROXIES.sample }
  # Works for all engines, but keep in mind that Selenium drivers doesn't support proxies
  # with authorization. Also, Mechanize doesn't support socks5 proxy format (only http)
  proxy: "3.4.5.6:3128:http:user:pass",

  # If enabled, browser will ignore any https errors. It's handy while using a proxy
  # with self-signed SSL cert (for example Crawlera or Mitmproxy)
  # Also, it will allow to visit webpages with expires SSL certificate.
  # Works for all engines
  ignore_ssl_errors: true,

  # Custom window size, works for all engines
  window_size: [1366, 768],

  # Skip images downloading if true, works for all engines
  disable_images: true,

  # Selenium engines only: headless mode, `:native` or `:virtual_display` (default is :native)
  # Although native mode has a better performance, virtual display mode
  # sometimes can be useful. For example, some websites can detect (and block)
  # headless chrome, so you can use virtual_display mode instead
  headless_mode: :native,

  # This option tells the browser not to use a proxy for the provided list of domains or IP addresses.
  # Format: array of strings. Works only for :selenium_firefox and selenium_chrome
  proxy_bypass_list: [],

  # Option to provide custom SSL certificate. Works only for :poltergeist_phantomjs and :mechanize
  ssl_cert_path: "path/to/ssl_cert",

  # Inject some JavaScript code to the browser.
  # Format: array of strings, where each string is a path to JS file.
  # Works only for poltergeist_phantomjs engine (Selenium doesn't support JS code injection)
  extensions: ["lib/code_to_inject.js"],

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
  skip_duplicate_requests: true,

  # Automatically skip provided errors while requesting a page.
  # If raised error matches one of the errors in the list, then this error will be caught,
  # and request will be skipped.
  # It is a good idea to skip errors like NotFound(404), etc.
  # Format: array where elements are error classes or/and hashes. You can use hash format
  # for more flexibility: `{ error: "RuntimeError", message: "404 => Net::HTTPNotFound" }`.
  # Provided `message:` will be compared with a full error message using `String#include?`. Also
  # you can use regex instead: `{ error: "RuntimeError", message: /404|403/ }`.
  skip_request_errors: [{ error: RuntimeError, message: "404 => Net::HTTPNotFound" }],

  # Automatically retry provided errors with a few attempts while requesting a page.
  # If raised error matches one of the errors in the list, then this error will be caught
  # and the request will be processed again within a delay. There are 3 attempts:
  # first: delay 15 sec, second: delay 30 sec, third: delay 45 sec.
  # If after 3 attempts there is still an exception, then the exception will be raised.
  # It is a good idea to try to retry errros like `ReadTimeout`, `HTTPBadGateway`, etc.
  # Format: same like for `skip_request_errors` option.
  retry_request_errors: [Net::ReadTimeout],

  # Handle page encoding while parsing html response using Nokogiri. There are two modes:
  # Auto (`:auto`) (try to fetch correct encoding from <meta http-equiv="Content-Type"> or <meta charset> tags)
  # Set required encoding manually, example: `encoding: "GB2312"` (Set required encoding manually)
  # Default this option is unset.
  encoding: nil,

  # Restart browser if one of the options is true:
  restart_if: {
    # Restart browser if provided memory limit (in kilobytes) is exceeded (works for all engines)
    memory_limit: 350_000,

    # Restart browser if provided requests limit is exceeded (works for all engines)
    requests_limit: 100
  },

  # Perform several actions before each request:
  before_request: {
    # Change proxy before each request. The `proxy:` option above should be presented
    # and has lambda format. Works only for poltergeist and mechanize engines
    # (Selenium doesn't support proxy rotation).
    change_proxy: true,

    # Change user agent before each request. The `user_agent:` option above should be presented
    # and has lambda format. Works only for poltergeist and mechanize engines
    # (selenium doesn't support to get/set headers).
    change_user_agent: true,

    # Clear all cookies before each request, works for all engines
    clear_cookies: true,

    # If you want to clear all cookies + set custom cookies (`cookies:` option above should be presented)
    # use this option instead (works for all engines)
    clear_and_set_cookies: true,

    # Global option to set delay between requests.
    # Delay can be `Integer`, `Float` or `Range` (`2..5`). In case of a range,
    # delay number will be chosen randomly for each request: `rand (2..5) # => 3`
    delay: 1..3
  }
}
```

As you can see, most of the options are universal for any engine.

### `@config` settings inheritance
Settings can be inherited:

```ruby
class ApplicationSpider < Kimurai::Base
  @engine = :poltergeist_phantomjs
  @config = {
    user_agent: "Firefox",
    disable_images: true,
    restart_if: { memory_limit: 350_000 },
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

Here, `@config` of `CustomSpider` will be _[deep merged](https://apidock.com/rails/Hash/deep_merge)_ with `ApplicationSpider` config, so `CustomSpider` will keep all inherited options with only `delay` updated.

## Project mode

Kimurai can work in project mode ([Like Scrapy](https://doc.scrapy.org/en/latest/intro/tutorial.html#creating-a-project)). To generate a new project, run: `$ kimurai generate project web_spiders` (where `web_spiders` is a name of project).

Structure of the project:

```bash
.
├── config/
│   ├── initializers/
│   ├── application.rb
│   ├── automation.yml
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

* `config/` folder for configutation files
  * `config/initializers` [Rails-like initializers](https://guides.rubyonrails.org/configuring.html#using-initializer-files) to load custom code at start of framework
  * `config/application.rb` configuration settings for Kimurai (`Kimurai.configure do` block)
  * `config/automation.yml` specify some settings for [setup and deploy](#automated-sever-setup-and-deployment)
  * `config/boot.rb` loads framework and project
  * `config/schedule.rb` Cron [schedule for spiders](#schedule-spiders-using-cron)
* `spiders/` folder for spiders
  * `spiders/application_spider.rb` Base parent class for all spiders
* `db/` store here all database files (`sqlite`, `json`, `csv`, etc.)
* `helpers/` Rails-like helpers for spiders
  * `helpers/application_helper.rb` all methods inside ApplicationHelper module will be available for all spiders
* `lib/` put here custom Ruby code
* `log/` folder for logs
* `pipelines/` folder for [Scrapy-like](https://doc.scrapy.org/en/latest/topics/item-pipeline.html) pipelines. One file = one pipeline
  * `pipelines/validator.rb` example pipeline to validate item
  * `pipelines/saver.rb` example pipeline to save item
* `tmp/` folder for temp. files
* `.env` file to store ENV variables for project and load them using [Dotenv](https://github.com/bkeepers/dotenv)
* `Gemfile` dependency file
* `Readme.md` example project readme
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

    # Drop item if it's category is not "shoe":
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
class GithubSpider < ApplicationSpider
  @name = "github_spider"
  @engine = :selenium_chrome
  @pipelines = [:validator]
  @start_urls = ["https://github.com/search?q=Ruby%20Web%20Scraping"]
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    before_request: { delay: 4..7 }
  }

  def parse(response, url:, data: {})
    response.xpath("//ul[@class='repo-list']/div//h3/a").each do |a|
      request_to :parse_repo_page, url: absolute_url(a[:href], base: url)
    end

    if next_page = response.at_xpath("//a[@class='next_page']")
      request_to :parse, url: absolute_url(next_page[:href], base: url)
    end
  end

  def parse_repo_page(response, url:, data: {})
    item = {}

    item[:owner] = response.xpath("//h1//a[@rel='author']").text
    item[:repo_name] = response.xpath("//h1/strong[@itemprop='name']/a").text
    item[:repo_url] = url
    item[:description] = response.xpath("//span[@itemprop='about']").text.squish
    item[:tags] = response.xpath("//div[@id='topics-list-container']/div/a").map { |a| a.text.squish }
    item[:watch_count] = response.xpath("//ul[@class='pagehead-actions']/li[contains(., 'Watch')]/a[2]").text.squish.delete(",").to_i
    item[:star_count] = response.xpath("//ul[@class='pagehead-actions']/li[contains(., 'Star')]/a[2]").text.squish.delete(",").to_i
    item[:fork_count] = response.xpath("//ul[@class='pagehead-actions']/li[contains(., 'Fork')]/a[2]").text.squish.delete(",").to_i
    item[:last_commit] = response.xpath("//span[@itemprop='dateModified']/*").text

    send_item item
  end
end
```

```
$ bundle exec kimurai crawl github_spider

I, [2018-08-22 15:56:35 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Spider: started: github_spider
D, [2018-08-22 15:56:35 +0400#1358] [M: 47347279209980] DEBUG -- github_spider: BrowserBuilder (selenium_chrome): created browser instance
I, [2018-08-22 15:56:40 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Browser: started get request to: https://github.com/search?q=Ruby%20Web%20Scraping
I, [2018-08-22 15:56:44 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Browser: finished get request to: https://github.com/search?q=Ruby%20Web%20Scraping
I, [2018-08-22 15:56:44 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Info: visits: requests: 1, responses: 1
D, [2018-08-22 15:56:44 +0400#1358] [M: 47347279209980] DEBUG -- github_spider: Browser: driver.current_memory: 116182
D, [2018-08-22 15:56:44 +0400#1358] [M: 47347279209980] DEBUG -- github_spider: Browser: sleep 5 seconds before request...

I, [2018-08-22 15:56:49 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Browser: started get request to: https://github.com/lorien/awesome-web-scraping
I, [2018-08-22 15:56:50 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Browser: finished get request to: https://github.com/lorien/awesome-web-scraping
I, [2018-08-22 15:56:50 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Info: visits: requests: 2, responses: 2
D, [2018-08-22 15:56:50 +0400#1358] [M: 47347279209980] DEBUG -- github_spider: Browser: driver.current_memory: 217432
D, [2018-08-22 15:56:50 +0400#1358] [M: 47347279209980] DEBUG -- github_spider: Pipeline: starting processing item through 1 pipeline...
I, [2018-08-22 15:56:50 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Pipeline: processed: {"owner":"lorien","repo_name":"awesome-web-scraping","repo_url":"https://github.com/lorien/awesome-web-scraping","description":"List of libraries, tools and APIs for web scraping and data processing.","tags":["awesome","awesome-list","web-scraping","data-processing","python","javascript","php","ruby"],"watch_count":159,"star_count":2423,"fork_count":358,"last_commit":"4 days ago"}
I, [2018-08-22 15:56:50 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Info: items: sent: 1, processed: 1
D, [2018-08-22 15:56:50 +0400#1358] [M: 47347279209980] DEBUG -- github_spider: Browser: sleep 6 seconds before request...

...

I, [2018-08-22 16:11:50 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Browser: started get request to: https://github.com/preston/idclight
I, [2018-08-22 16:11:51 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Browser: finished get request to: https://github.com/preston/idclight
I, [2018-08-22 16:11:51 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Info: visits: requests: 140, responses: 140
D, [2018-08-22 16:11:51 +0400#1358] [M: 47347279209980] DEBUG -- github_spider: Browser: driver.current_memory: 211713

D, [2018-08-22 16:11:51 +0400#1358] [M: 47347279209980] DEBUG -- github_spider: Pipeline: starting processing item through 1 pipeline...
E, [2018-08-22 16:11:51 +0400#1358] [M: 47347279209980] ERROR -- github_spider: Pipeline: dropped: #<Kimurai::Pipeline::DropItemError: Repository doesn't have enough stars>, item: {:owner=>"preston", :repo_name=>"idclight", :repo_url=>"https://github.com/preston/idclight", :description=>"A Ruby gem for accessing the freely available IDClight (IDConverter Light) web service, which convert between different types of gene IDs such as Hugo and Entrez. Queries are screen scraped from http://idclight.bioinfo.cnio.es.", :tags=>[], :watch_count=>6, :star_count=>1, :fork_count=>0, :last_commit=>"on Apr 12, 2012"}

I, [2018-08-22 16:11:51 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Info: items: sent: 127, processed: 12

I, [2018-08-22 16:11:51 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Browser: driver selenium_chrome has been destroyed
I, [2018-08-22 16:11:51 +0400#1358] [M: 47347279209980]  INFO -- github_spider: Spider: stopped: {:spider_name=>"github_spider", :status=>:completed, :environment=>"development", :start_time=>2018-08-22 15:56:35 +0400, :stop_time=>2018-08-22 16:11:51 +0400, :running_time=>"15m, 16s", :visits=>{:requests=>140, :responses=>140}, :items=>{:sent=>127, :processed=>12}, :error=>nil}
```
</details><br>

Also, you can pass custom options to pipeline from a particular spider if you want to change pipeline behavior for this spider:

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

Each spider runs in a separate process. Spiders logs available at `log/` folder. Pass `-j` option to specify how many spiders should be processed at the same time (default is 1).

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
Will be updated

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
