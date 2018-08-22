class Validator < Kimurai::Pipeline
  def process_item(item, options: {})
    # Here you can validate item and raise `DropItemError`
    # if one of the validations failed. Examples:

    # Check item sku for uniqueness using buit-in `unique?` helper:
    # unless unique?(:sku, item[:sku])
    #   raise DropItemError, "Item sku is not unique"
    # end

    # Drop item if title length shorter than 5 symbols:
    # if item[:title].size < 5
    #   raise DropItemError, "Item title is short"
    # end

    # Drop item if it doesn't contains any images:
    # unless item[:images].present?
    #   raise DropItemError, "Item images are not present"
    # end

    # Pass item to the next pipeline (if it wasn't dropped)
    item
  end
end
