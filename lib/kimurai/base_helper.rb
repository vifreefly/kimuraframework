module Kimurai
  module BaseHelper
    private

    def absolute_url(url, base:)
      return unless url

      URI.join(base, URI::DEFAULT_PARSER.escape(url)).to_s
    end

    def escape_url(url)
      URI.parse(url)
    rescue URI::InvalidURIError
      URI.parse(URI::DEFAULT_PARSER.escape(url)).to_s rescue url
    else
      url
    end

    def normalize_url(url, base:)
      escape_url(absolute_url(url, base: base))
    end
  end
end
