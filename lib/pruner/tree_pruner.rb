# frozen_string_literal: true

module Pruner
  class TreePruner
    TREE_NODE_NAMES = ENV['TREE_NODE_NAMES'].split(',')

    def initialize(tree, ids)
      raise ArgumentError, "'tree' must be an Array" unless tree.is_a?(Array)
      raise ArgumentError, "'ids' must be an Array" unless ids.is_a?(Array)
      raise ArgumentError, "'ids' must consist of Integers" unless ids.all? { |id| id.is_a?(Integer) }
      @tree, @ids = tree, ids
    end

    def call
      return tree if tree_pruned? || tree.empty? || ids.empty?
      search_tree(tree)
      logger.info m: "ids '#{ids - ids_found}' weren't found!" if ids - ids_found != []
      return [] if ids_found.empty?
      prune_tree(tree)
      tree
    end

    private

    attr_accessor :tree, :ids

    # Searches a tree for the requested ids recursively
    # depth == 0 means start from the root
    #
    # @param node [Hash]
    # @param depth [Integer]
    # @param path [Array] Preserves the path to each interesting id
    #
    def search_tree(node, depth = 0, path = [])
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

          # If all ids were found - stop searching
          return if ids - ids_found == []
        end
      end
    end

    # Prunes a tree recursively
    # depth == 0 means start from the root
    #
    # transposed_paths contains the ids that should be preserved
    # on each depth(layer) of the tree, everything else is removed
    #
    # @param node [Hash]
    # @param depth [Integer]
    #
    def prune_tree(node, depth = 0)
      node.delete_if { |subnode| !transposed_paths[depth].include?(subnode['id']) }
      node.each do |subnode|
        if subnode[TREE_NODE_NAMES[depth]].is_a?(Array)
          prune_tree(subnode[TREE_NODE_NAMES[depth]], depth + 1)
        end
      end
      tree_pruned!
    end

    def ids_found
      @ids_found ||= []
    end

    def paths
      @paths ||= []
    end

    def transposed_paths
      @transposed_paths ||= paths.transpose
    end

    def tree_pruned!
      @tree_pruned = true
    end

    def tree_pruned?
      @tree_pruned ||= false
    end

    def logger
      Pruner.logger
    end
  end
end
