require 'addressable/uri'

module Kimurai
  module BaseHelper
    private

    def absolute_url(url, base:)
      return unless url
      URI.join(base, Addressable::URI.escape(url)).to_s
    end

    def escape_url(url)
      uri = URI.parse(url)
    rescue URI::InvalidURIError => e
      URI.parse(Addressable::URI.escape(url)).to_s rescue url
    else
      url
    end

    def normalize_url(url, base:)
      escape_url(absolute_url(url, base: base))
    end
  end
end
