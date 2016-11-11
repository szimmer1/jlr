require 'hana'

module Jlr
    class Var
      attr_accessor :arg, :default
      def initialize arg, default=nil
        @arg = arg
        @default = default
      end

      def evaluate data
        result = nil

        evaluated = Jlr.evaluate(@arg, data)

        if evaluated.is_a?(Integer)
          # if integer, try to access array index
          result = data[evaluated]
        else
          # if string, try to access by JSON Pointer
          p = Hana::Pointer.new(evaluated.gsub('.','/'))
          result = p.eval(data)
        end

        result.nil? ? @default : result
      end
    end
end