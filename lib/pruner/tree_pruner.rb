# frozen_string_literal: true

require 'pry'

module Pruner
  class TreePruner
    TREE_NODE_NAMES = ENV['TREE_NODE_NAMES'].split(',')

    def initialize(tree, ids)
      raise ArgumentError, "'tree' must be an Array" unless tree.is_a?(Array)
      raise ArgumentError, "'ids' must be an Array" unless ids.is_a?(Array)
      raise ArgumentError, "'ids' must be Integers" unless ids.all? { |id| id.is_a?(Integer) }
      @tree, @ids = tree, ids
    end

    def call
      search_tree(tree, 0)
      logger.warn m: "ids '#{ids - ids_found}' weren't found!" if ids - ids_found != []
      logger.info paths
      # binding.pry
    end

    private

    attr_accessor :tree, :ids

    # Searches a tree for the requested ids recursively
    # depth == 0 means start from the root
    #
    # @param node [Hash]
    # @param depth [Integer]
    # @param path [Array] Preserves the path represented by ids
    #
    def search_tree(node, depth, path = [])
      node.each do |subnode|
        if subnode[TREE_NODE_NAMES[depth]].is_a?(Array)
          search_tree(subnode[TREE_NODE_NAMES[depth]], depth + 1, path + [subnode['id']])
        else
          # The deepest node is reached.
          # If an id found is interesting, preserve the path
          if ids.include?(subnode['id'])
            paths << path + [subnode['id']]
            ids_found << subnode['id']
          end

          # Stop searching if all the ids were found
          return if ids - ids_found == []
        end
      end
    end

    def paths
      @paths ||= []
    end

    def ids_found
      @ids_found ||= []
    end

    def logger
      Pruner.logger
    end
  end
end
