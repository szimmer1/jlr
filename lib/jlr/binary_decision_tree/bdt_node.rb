module Jlr
  module BinaryDecisionTree
    class BdtNode < BinaryTree::BtNode
      attr_accessor :if, :then, :else
      def initialize(_if=nil, _then=nil, _else=nil)
        @if = _if
        @then = _then
        @else = _else
      end

      def evaluate _data
        if Jlr.truthy(Jlr.evaluate(@if,_data))
          Jlr.evaluate(@then, _data)
        else
          Jlr.evaluate(@else, _data)
        end
      end
    end
  end
end