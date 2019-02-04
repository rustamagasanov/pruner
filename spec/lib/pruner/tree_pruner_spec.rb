# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pruner::TreePruner do
  let(:tree_path) do
    File.expand_path('../../../fixtures/tree.json', __FILE__)
  end
  let(:tree) { JSON.parse(File.read(tree_path)) }

  describe '.new' do
    it 'raises error if tree is not an Array' do
      expect { described_class.new(123, [1, 2]) }.to raise_exception(
        ArgumentError, "'tree' must be an Array"
      )
    end

    it 'raises error if ids is not an Array' do
      expect { described_class.new([1, 2], 123) }.to raise_exception(
        ArgumentError, "'ids' must be an Array"
      )
    end

    it 'raises error if ids are not Integers' do
      expect { described_class.new([1, 2], [1, '2']) }.to raise_exception(
        ArgumentError, "'ids' must consist of Integers"
      )
    end
  end

  describe '#call' do
    it 'returns an empty tree if tree was empty' do
      pruner = described_class.new([], [1, 2])
      expect(pruner.call).to eql([])
    end

    it 'returns an empty tree if ids was empty' do
      pruner = described_class.new([1, 2], [])
      expect(pruner.call).to eql([1, 2])
    end

    it 'returns an empty tree none of the ids were found' do
      pruner = described_class.new(tree, [999])
      expect(pruner.call).to eql([])
    end

    it 'returns a pruned tree if at least one of ids was found' do
      pruner = described_class.new(tree, [999, 1])
      expect(pruner.call).to eql(
       [{"id"=>2,
         "name"=>"Demographics",
         "sub_themes"=>
         [{"categories"=>
            [{"id"=>11,
               "indicators"=>[{"id"=>1, "name"=>"total"}],
               "name"=>"Crude death rate",
               "unit"=>"(deaths per 1000 people)"}],
            "id"=>4,
            "name"=>"Births and Deaths"}]}]
      )
    end

    it 'returns a properly pruned tree' do
      pruner = described_class.new(tree, [31, 32, 1])
      expect(pruner.call).to eql(
        [{"id"=>2,
         "name"=>"Demographics",
         "sub_themes"=>
          [{"categories"=>
             [{"id"=>11,
               "indicators"=>[{"id"=>1, "name"=>"total"}],
               "name"=>"Crude death rate",
               "unit"=>"(deaths per 1000 people)"}],
            "id"=>4,
            "name"=>"Births and Deaths"}]},
        {"id"=>3,
         "name"=>"Jobs",
         "sub_themes"=>
          [{"categories"=>
             [{"id"=>23,
               "indicators"=>
                [{"id"=>31, "name"=>"Total"}, {"id"=>32, "name"=>"Female"}],
               "name"=>"Unemployment rate, 15–24 years, usual",
               "unit"=>"(percent of labor force)"}],
            "id"=>8,
            "name"=>"Unemployment"}]}]
      )
    end
  end
end
