require 'spec_helper'

describe Jlr::Var do
  describe 'initialize/compile' do
    it 'should work with array & non-array args' do
      a = Jlr::Var.new(['a'])
      non_a = Jlr::Var.new('a')
      a.arg.should == 'a'
      non_a.arg.should == 'a'
    end

    it 'should capture default value correctly' do
      a = Jlr::Var.new(['a'])
      a_default = Jlr::Var.new(['a', 3])
      non_a = Jlr::Var.new('a')

      a.default.should == nil
      non_a.default.should == nil
      a_default.default.should == 3
    end
  end

  describe 'evaluate' do
    describe 'integer' do
      it 'should raise if data is not an array' do
        lambda{ Jlr::Var.new(1).evaluate({}) }.should raise_error(Jlr::Error)
      end
    end

    describe 'string' do
      it 'json pointer returns nil if DNE' do
        Jlr::Var.new('hello/world').evaluate({'hi' => 1}).should == nil
      end
      it 'json pointer returns nested array indices' do
        Jlr::Var.new('hello/1').evaluate({'hello' => [0,'correct',nil]}).should == 'correct'
      end
    end
  end
end