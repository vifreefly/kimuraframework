class Hash
  def deep_merge_excl(second, exclude)
    self.merge(second.slice(*exclude)).deep_merge(second.except(*exclude))
  end
end
