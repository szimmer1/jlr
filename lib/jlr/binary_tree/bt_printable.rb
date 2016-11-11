module Jlr
  module BinaryTree
    module BtPrintable
      def to_s offset=1
        ret = data.inspect
        ret << ("\n" + ' ' * offset + '|--' +  left.to_s(offset + 4))  if left
        ret << ("\n" + ' ' * offset + '|--' +  right.to_s(offset + 4)) if right
        ret
      end
    end
  end
end