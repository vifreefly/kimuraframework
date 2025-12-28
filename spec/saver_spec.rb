require 'spec_helper'
require 'tempfile'
require 'fileutils'

RSpec.describe Kimurai::Base::Saver do
  let(:temp_dir) { Dir.mktmpdir }
  let(:file_path) { File.join(temp_dir, 'output') }

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '#initialize' do
    it 'accepts valid formats' do
      %i[json pretty_json jsonlines csv].each do |format|
        expect { described_class.new(file_path, format: format) }.not_to raise_error
      end
    end

    it 'raises error for invalid format' do
      expect { described_class.new(file_path, format: :xml) }
        .to raise_error(/wrong type of format: xml/)
    end

    it 'sets default options' do
      saver = described_class.new(file_path, format: :json)
      expect(saver.format).to eq(:json)
      expect(saver.path).to eq(file_path)
      expect(saver.position).to eq(true)
      expect(saver.append).to eq(false)
    end

    it 'accepts custom options' do
      saver = described_class.new(file_path, format: :csv, position: false, append: true)
      expect(saver.position).to eq(false)
      expect(saver.append).to eq(true)
    end
  end

  describe '#save with JSON format' do
    let(:saver) { described_class.new(file_path, format: :json) }

    it 'saves single item with position' do
      saver.save({ name: 'Alice', age: 30 })

      result = JSON.parse(File.read(file_path), symbolize_names: true)
      expect(result).to eq([{ name: 'Alice', age: 30, position: 1 }])
    end

    it 'saves multiple items in sequence' do
      saver.save({ name: 'Alice', age: 30 })
      saver.save({ name: 'Bob', age: 25 })

      result = JSON.parse(File.read(file_path), symbolize_names: true)
      expect(result).to eq([
                             { name: 'Alice', age: 30, position: 1 },
                             { name: 'Bob', age: 25, position: 2 }
                           ])
    end

    it 'saves array of items' do
      saver.save([
                   { name: 'Alice', age: 30 },
                   { name: 'Bob', age: 25 }
                 ])

      result = JSON.parse(File.read(file_path), symbolize_names: true)
      expect(result).to eq([
                             { name: 'Alice', age: 30, position: 1 },
                             { name: 'Bob', age: 25, position: 2 }
                           ])
    end

    it 'saves without position when disabled' do
      saver = described_class.new(file_path, format: :json, position: false)
      saver.save({ name: 'Alice', age: 30 })

      result = JSON.parse(File.read(file_path), symbolize_names: true)
      expect(result).to eq([{ name: 'Alice', age: 30 }])
    end

    it 'appends to existing file when append is true' do
      # Create initial file
      File.write(file_path, '[{"name":"Charlie","age":35,"position":1}]')

      saver = described_class.new(file_path, format: :json, append: true)
      saver.save({ name: 'Alice', age: 30 })

      result = JSON.parse(File.read(file_path), symbolize_names: true)
      expect(result).to eq([
                             { name: 'Charlie', age: 35, position: 1 },
                             { name: 'Alice', age: 30, position: 1 }
                           ])
    end
  end

  describe '#save with pretty_json format' do
    let(:saver) { described_class.new(file_path, format: :pretty_json) }

    it 'saves formatted JSON with proper indentation' do
      saver.save({ name: 'Alice', age: 30 })

      content = File.read(file_path)
      expect(content).to include('  "name": "Alice"')
      expect(content).to include('  "age": 30')

      result = JSON.parse(content, symbolize_names: true)
      expect(result).to eq([{ name: 'Alice', age: 30, position: 1 }])
    end

    it 'appends multiple items with proper formatting' do
      saver.save({ name: 'Alice', age: 30 })
      saver.save({ name: 'Bob', age: 25 })

      result = JSON.parse(File.read(file_path), symbolize_names: true)
      expect(result).to eq([
                             { name: 'Alice', age: 30, position: 1 },
                             { name: 'Bob', age: 25, position: 2 }
                           ])
    end
  end

  describe '#save with jsonlines format' do
    let(:saver) { described_class.new(file_path, format: :jsonlines) }

    it 'saves single item as one line' do
      saver.save({ name: 'Alice', age: 30 })

      lines = File.read(file_path).split("\n")
      expect(lines.length).to eq(1)

      result = JSON.parse(lines[0], symbolize_names: true)
      expect(result).to eq({ name: 'Alice', age: 30, position: 1 })
    end

    it 'saves multiple items as separate lines' do
      saver.save({ name: 'Alice', age: 30 })
      saver.save({ name: 'Bob', age: 25 })

      lines = File.read(file_path).split("\n")
      expect(lines.length).to eq(2)

      alice = JSON.parse(lines[0], symbolize_names: true)
      bob = JSON.parse(lines[1], symbolize_names: true)

      expect(alice).to eq({ name: 'Alice', age: 30, position: 1 })
      expect(bob).to eq({ name: 'Bob', age: 25, position: 2 })
    end

    it 'saves array of items as separate lines' do
      saver.save([
                   { name: 'Alice', age: 30 },
                   { name: 'Bob', age: 25 }
                 ])

      lines = File.read(file_path).split("\n")
      expect(lines.length).to eq(2)
    end

    it 'appends to existing file when append is true' do
      File.write(file_path, '{"name":"Charlie","age":35,"position":1}')

      saver = described_class.new(file_path, format: :jsonlines, append: true)
      saver.save({ name: 'Alice', age: 30 })

      lines = File.read(file_path).split("\n")
      expect(lines.length).to eq(2)
    end
  end

  describe '#save with CSV format' do
    let(:saver) { described_class.new(file_path, format: :csv) }

    it 'saves single item with headers' do
      saver.save({ name: 'Alice', age: 30 })

      csv = CSV.read(file_path)
      expect(csv[0]).to eq(%w[name age position])
      expect(csv[1]).to eq(%w[Alice 30 1])
    end

    it 'saves multiple items without repeating headers' do
      saver.save({ name: 'Alice', age: 30 })
      saver.save({ name: 'Bob', age: 25 })

      csv = CSV.read(file_path)
      expect(csv.length).to eq(3) # 1 header + 2 data rows
      expect(csv[0]).to eq(%w[name age position])
      expect(csv[1]).to eq(%w[Alice 30 1])
      expect(csv[2]).to eq(%w[Bob 25 2])
    end

    it 'saves array of items' do
      saver.save([
                   { name: 'Alice', age: 30 },
                   { name: 'Bob', age: 25 }
                 ])

      csv = CSV.read(file_path)
      expect(csv.length).to eq(3)
    end

    it 'flattens nested hashes' do
      saver.save({ user: { name: 'Alice', age: 30 }, city: 'NYC' })

      csv = CSV.read(file_path)
      expect(csv[0]).to include('user.name', 'user.age', 'city', 'position')
      expect(csv[1]).to include('Alice', '30', 'NYC', '1')
    end

    it 'saves without position when disabled' do
      saver = described_class.new(file_path, format: :csv, position: false)
      saver.save({ name: 'Alice', age: 30 })

      csv = CSV.read(file_path)
      expect(csv[0]).to eq(%w[name age])
      expect(csv[1]).to eq(%w[Alice 30])
    end

    it 'appends to existing file when append is true' do
      CSV.open(file_path, 'w', force_quotes: true) do |csv|
        csv << %w[name age position]
        csv << %w[Charlie 35 1]
      end

      saver = described_class.new(file_path, format: :csv, append: true)
      saver.save({ name: 'Alice', age: 30 })

      csv = CSV.read(file_path)
      expect(csv.length).to eq(3)
      expect(csv[2]).to eq(%w[Alice 30 1])
    end

    it 'quotes all values' do
      saver.save({ name: 'Alice', age: 30 })

      content = File.read(file_path)
      expect(content).to include('"Alice"')
      expect(content).to include('"30"')
    end
  end

  describe 'thread safety' do
    let(:saver) { described_class.new(file_path, format: :jsonlines) }

    it 'handles concurrent saves correctly' do
      threads = 10.times.map do |i|
        Thread.new { saver.save({ thread: i, data: "test_#{i}" }) }
      end
      threads.each(&:join)

      lines = File.read(file_path).split("\n")
      expect(lines.length).to eq(10)

      positions = lines.map { |line| JSON.parse(line)['position'] }
      expect(positions.sort).to eq((1..10).to_a)
    end
  end

  describe '#flatten_hash (private method)' do
    let(:saver) { described_class.new(file_path, format: :csv) }

    it 'flattens deeply nested hashes' do
      saver.save({
                   user: {
                     profile: {
                       name: 'Alice',
                       age: 30
                     },
                     settings: {
                       theme: 'dark'
                     }
                   }
                 })

      csv = CSV.read(file_path)
      expect(csv[0]).to include('user.profile.name', 'user.profile.age', 'user.settings.theme')
    end

    it 'handles nil keys gracefully' do
      saver.save({ nil => 'value', 'key' => 'another' })

      csv = CSV.read(file_path)
      expect(csv[0]).to include('', 'key', 'position')
    end

    it 'preserves non-hash values' do
      saver.save({ name: 'Alice', tags: %w[ruby rails], count: 5 })

      CSV.read(file_path)
      content = File.read(file_path)
      expect(content).to include('Alice')
      expect(content).to include('5')
    end
  end
end
