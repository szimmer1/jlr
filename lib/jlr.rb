require 'jlr/version'
require 'jlr/binary_tree/bt_printable'
require 'jlr/binary_tree/bt_node'
require 'jlr/var'
require 'jlr/expression'
require 'jlr/binary_decision_tree/bdt_node'
require 'jlr/operators'
require 'active_support/core_ext/object'

module Jlr
  class Error < StandardError; end

  def self.apply rule, data
    compiled = compile(rule)
    compiled.respond_to?(:evaluate) ? compiled.evaluate(data) : compiled
  end

  # returns a structure representing the rule
  # the returned object will respond to evaluate(data)
  # and return the result of evaluating the rule
  def self.compile rule
    # return if the rule is a primitive
    return rule unless is_rule(rule)

    op = rule.keys.first

    raise UnknownOpError.new("Compile Error: operator #{op} not recognized") unless ALL_OPS.include?(op)

    if 'if' == op.to_s.strip
      _if, _then, _else, _elsif = rule[op]
      elsif_rule = _elsif ? { op => rule[op][2..-1] } : nil
      return BinaryDecisionTree::BdtNode.new(
        compile(_if),
        compile(_then),
        elsif_rule ? compile(elsif_rule) : compile(_else)
      )

    else
      # must be some evaluatable operator
      args = rule[op]
      args = [args] unless args.is_a?(Array)
      return Expression.new(
        op, *(args.map(&method(:compile)))
      )

    end
  end

  def self.evaluate arg, data
    arg.respond_to?(:evaluate) ? arg.evaluate(data) : arg.respond_to?(:data) ? arg.data : arg
  end

  def self.truthy value
    return false if value == 0
    !value.blank?
  end

  def self.is_rule rule
    rule.is_a?(Hash)
  end

  def self.is_rule_type opts=nil
    ->(rule) {
      if opts
        is_rule(rule) && opts.include?(rule.keys.first.to_s.strip)
      else
        is_rule(rule)
      end
    }
  end
end
