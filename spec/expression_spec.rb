require 'spec_helper'

describe 'expression' do
  it 'should allow primitives as args' do
    Jlr::Expression.new('+', 1,2).evaluate({}).should == 3
  end
end