RSpec.describe Kimurai::Base do 
  describe '.running?' do
    pending
  end

  describe '.completed?' do
    pending
  end

  describe '.failed?' do
    pending
  end

  describe '.visits' do
    pending
  end

  describe '.items' do
    pending
  end

  describe '.update' do
    pending
  end

  describe '.add_event' do
    pending
  end

  describe '.name' do
    pending
  end

  describe '.engine' do
    pending
  end

  describe '.pipelines' do
    pending
  end

  describe '.start_urls' do
    pending
  end

  describe '.config' do
    pending
  end

  describe '.logger' do
    pending
  end

  describe '.crawl!' do
    pending
  end

  describe '.parse!' do
    pending
  end

  describe '#browser' do
    pending
  end

  describe '#request_to' do
    pending
  end

  describe '#console' do
    pending
  end

  describe '#storage' do
    pending
  end

  describe '#unique?' do
    pending
  end

  describe "#save_to" do
    let(:item) { double('item') }
    let(:path) { '/path/to/file' }
    let(:format) { :csv }
    let(:position) { true }
    let(:append) { false }

    context "when the Saver instance does not exist" do
      it "creates a new Saver instance and stores it in the @savers instance variable" do
        saver = instance_double(Kimurai::Base::Saver)
        expect(saver).to receive(:save).with(item)
        expect(Kimurai::Base::Saver).to receive(:new).with(path, format: format, position: position, append: append).and_return(saver)
        allow(described_class).to receive(:savers).and_return({})

        subject.save_to(path, item, format: format, position: position, append: append)

        expect(subject.instance_variable_get(:@savers)[path]).to eq(saver)
        expect(subject.class.savers[path]).to eq(nil)
      end

      context "when the with_info class method returns true" do
        it "stores the Saver instance in the savers class variable" do
          saver = instance_double(Kimurai::Base::Saver)
          expect(saver).to receive(:save).with(item)
          expect(subject).to receive(:with_info).and_return(true)
          expect(Kimurai::Base::Saver).to receive(:new).with(path, format: format, position: position, append: append).and_return(saver)
          allow(described_class).to receive(:savers).and_return({})

          subject.save_to(path, item, format: format, position: position, append: append)

          expect(subject.instance_variable_get(:@savers)[path]).to eq(saver)
          expect(subject.class.savers[path]).to eq(saver)
        end
      end
    end

    context "when the Saver instance already exists" do
      it "does not create a new Saver instance" do
        saver = instance_double(Kimurai::Base::Saver)
        expect(saver).to receive(:save).with(item)
        subject.instance_variable_set(:@savers, { path => saver })
        expect(Kimurai::Base::Saver).not_to receive(:new)
        subject.save_to(path, item, format: format, position: position, append: append)
      end
    end
  end


  describe '#add_event' do
    pending
  end
end
