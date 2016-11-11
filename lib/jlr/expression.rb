module Jlr
    class Expression
      attr_accessor :args, :op, :op_proc
      def initialize *attrs
        @op = attrs[0]
        @op_proc = Jlr.get_op_proc(@op)
        @args = attrs[1..-1]

        # compile-time checks
        raise UnknownOpError.new("#{@op} is not known") unless @op_proc

        # check that numeric ops have correct number of arguments
        if NUMERIC_OPS.include?(@op) && ! (@args.size == 2)
          raise OpArgError.new("op #{@op} is neither unary, ternary, nor associative, given #{@args.size} args") \
            unless UNARY_OPS.include?(@op) || ASSOCIATIVE_OPS.include?(@op) || TERNARY_OPS.include?(@op) || @op == 'merge'
          raise OpArgError.new("op #{@op} is unary and not associative, given #{@args.size} args") if
              (UNARY_OPS - ASSOCIATIVE_OPS).include?(@op) && @args.size > 1
        end

        # TODO check (compile time) that "between" has correct number of args
      end

      def evaluate data, args=nil
        args ||= @args.clone
        # TODO handle special cases
        # TODO unary +: cast to number
        # TODO unary -: return the opposite

        # handle associative operators recursively
        if ASSOCIATIVE_OPS.include?(@op) && args.size > 2
          shifted = args.shift
          @op_proc.call(evaluate(data, args), Jlr.evaluate(shifted, data))
        else
          if BOOLEAN_LOGIC_OPS.include?(@op) || DATA_OPS.include?(@op)
            # handle evaluation in the proc for short circuit evaluation
            @op_proc.call(data, *args)
          else
            @op_proc.call(*(args.map { |arg| Jlr.evaluate(arg, data) }))
          end
        end
      end
    end
end