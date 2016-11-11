require 'spec_helper'

describe 'operators' do
  describe 'associative' do
    Jlr::ASSOCIATIVE_OPS.each do |op|
      it "op #{op} should not raise_error error for > 2 args" do
        lambda { Jlr::Expression.new(op, 1,2,3).evaluate({}) }.should_not raise_error(Exception)
      end
    end
  end
end