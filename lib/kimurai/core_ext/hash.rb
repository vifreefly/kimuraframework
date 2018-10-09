class Hash
  def deep_merge_excl(second, exclude)
    merge(second.slice(*exclude)).deep_merge(second.except(*exclude))
  end
end
