module Jlr
  class UnknownOpError < StandardError; end
  class OpArgError < StandardError; end

  DECISION_TREE_OPS = %w(if)
  BOOLEAN_LOGIC_OPS = %w(and or)
  DATA_OPS          = %w(var missing missing_some)
  ARRAY_OPS         = %w(in merge)
  STRING_OPS        = %w(cat)
  ARITHMETIC_OPS    = %w(+ - * / %)
  NUMERIC_OPS       = %w(< > <= >= == === != !== max min) + ARITHMETIC_OPS
  TERNARY_OPS       = %w(< <= ?:)
  ASSOCIATIVE_OPS   = %w(+ * max min)
  UNARY_OPS         = %w(+ - ! !!)
  ALL_OPS           = (
    DECISION_TREE_OPS +
    BOOLEAN_LOGIC_OPS +
    NUMERIC_OPS +
    DATA_OPS +
    ARRAY_OPS +
    STRING_OPS +
    TERNARY_OPS +
    UNARY_OPS).uniq

  def self.between inclusive, *args
    args = args[0] if args.size == 1 && args[0].is_a?(Array) # handle case of passing in array

    if args.size == 2
      inclusive ? (:<=).to_proc.call(*args) : (:<).to_proc.call(*args)
    elsif args.size == 3
      low, target, high = args
      inclusive ? (low..high).include?(target) : (low...high).include?(target) && target != low
    else
      raise OpArgError.new("Between expected 2 or 3 args. Given #{args.inspect}.") unless (2..3).include?(args.size)
    end
  end

  def self.missing data, *list
    list.map {|expr| Jlr.evaluate(expr, data) }
      .flatten
      .map { |evald| [evald, Var.new(evald).evaluate(data)] }
      .select {|p,v| v.nil? }
      .map(&:first)
  end

  def self.get_op_proc op_str
    {
        '!' => ->(arg) { ! Jlr.truthy(arg) },
        '!!' => ->(arg) { Jlr.truthy(arg) },
        '+' => ->(m,n=nil) { n ? m.to_f + n.to_f : m.to_f },
        '-' => ->(m,n=nil) { n ? m.to_f - n.to_f : -m },
        '*' => ->(m,n=nil) { n ? m.to_f * n.to_f : m },
        '/' => ->(m,n) { m.to_f / n.to_f },
        '%' => ->(m,n) { m.to_f % n.to_f },
        '<' => ->(*args) { between(false, *(args.map(&:to_f))) },
        '<=' => ->(*args) { between(true, *(args.map(&:to_f))) },
        '>' => ->(m,n) { m.to_f > n.to_f },
        '>=' => ->(m,n) { m.to_f >= n.to_f },
        '==' => ->(m,n) { m.to_s == n.to_s },
        '===' => (:==).to_proc,
        '!=' => ->(m,n) { m.to_s != n.to_s },
        '!==' => (:!=).to_proc,
        'max' => ->(*args) { args.max },
        'min' => ->(*args) { args.min },
        'in' => ->(subseq, seq) { seq.include?(subseq) },
        'merge' => ->(*args) { args.inject([]){|m,n| m + (n.is_a?(Array) ? n : [n]) }},
        'cat' => ->(*args) { args.join },
        '?:' => ->(condition,t,f) { Jlr.truthy(condition) ? t : f },

        # DATA_OPS
        'var' => ->(data, path, default=nil) { Var.new(path,default).evaluate(data) },
        'missing' => method(:missing),
        'missing_some' => ->(data, *args) {
          min, list = args
          missed = missing(data, *list)
          missed.size < min ? [] : missed
        },

        # The BOOLEAN_LOGIC_OPS do short-circuit evaluation
        'or' => ->(data, *args) {
          args.each do |arg|
            evald = Jlr.evaluate(arg, data)
            return evald if Jlr.truthy(evald)
          end
          false
        },
        'and' => ->(data, *args) {
          last_evald = nil
          args.each do |arg|
            last_evald = Jlr.evaluate(arg, data)
            return false unless Jlr.truthy(last_evald)
          end
          last_evald
        }
    }[op_str]
  end
end