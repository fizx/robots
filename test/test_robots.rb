#!/usr/bin/env ruby
require "test/unit"
require File.dirname(__FILE__) + "/../lib/robots"

class TestRobots < Test::Unit::TestCase
  
  def test_allowed_if_no_robots
    assert Robots.new("Foo").allowed?("http://www.yahoo.com")
  end
end