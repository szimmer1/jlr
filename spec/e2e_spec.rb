require 'spec_helper'
require 'net/http'
require 'uri'
require 'oj'

describe 'end-to-end' do
  CACHE_DIR = File.join(File.dirname(__FILE__),'..','tmp','end2end_test_cases')
  DEST_FILE = File.join(CACHE_DIR, 'test_cases.json')

  unless File.exist?(CACHE_DIR)
    url = URI.parse('http://jsonlogic.com/tests.json')
    test_json = Net::HTTP.get_response(url).body
    File.open(DEST_FILE,'w') {|f| f.write(test_json) }
  end

  test_json ||= File.read(DEST_FILE)
  test_arr = Oj.load(test_json)

  switch = true
  test_arr.each do |test|
    #switch = test =~ /if\/then/i ? true : false if test.is_a?(String)
    next unless switch && ! test.is_a?(String)
    it test.inspect do
      rule, data, expected = test
      Jlr.apply(rule, data).should == expected
    end
  end
end