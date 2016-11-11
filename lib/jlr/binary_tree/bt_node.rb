module Jlr
  module BinaryTree
    class BtNode
      include BtPrintable

      attr_accessor :left, :right, :data
      def initialize(left=nil, right=nil, data=nil)
        @left = left
        @right = right
        @data = data
      end
    end
  end
end