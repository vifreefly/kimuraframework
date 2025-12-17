class Saver < Kimurai::Pipeline
  def process_item(item, options: {})
    # Here you can save item to the database, send it to a remote API or
    # simply save item to a file format using `save_to` helper:

    # To get the name of a current spider: `spider.class.name`
    # save_to "db/#{spider.class.name}.json", item, format: :pretty_json

    item
  end
end
