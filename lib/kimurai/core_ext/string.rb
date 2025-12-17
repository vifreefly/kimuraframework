# frozen_string_literal: true

require 'murmurhash3'

class String
  def to_id
    MurmurHash3::V32.str_hash(self)
  end
end
