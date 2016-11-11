$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jlr'

RSpec.configure do |conf|
  conf.expect_with(:rspec) {|c| c.syntax = :should }
end