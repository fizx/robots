#!/usr/bin/env ruby
require "test/unit"
require File.dirname(__FILE__) + "/../lib/robots"

class TestRobots < Test::Unit::TestCase
  def setup
    @robots = Robots.new "Ruby-Robot.txt Parser Test Script"
  end
  
  def test_allowed_if_no_robots
    assert @robots.allowed?("http://www.yahoo.com")
  end
  
  def test_
    assert @robots.allowed?("http://www.yelp.com/foo")
    assert !@robots.allowed?("http://www.yelp.com/mail?foo=bar")
  end
end