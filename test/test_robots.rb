#!/usr/bin/env ruby
require "test/unit"
require File.dirname(__FILE__) + "/../lib/robots"

module Kernel
  alias_method :open_old, :open
  
  def set_open(key, value)
    @fake_open_values ||= {}
    @fake_open_values[key] = value
  end
  
  def open(*args)
    @fake_open_values ||= {}
    @fake_open_values[args.first] || open_old(*args)
  end
end

class TestRobots < Test::Unit::TestCase
  def setup
    @robots = Robots.new "Ruby-Robot.txt Parser Test Script"
  end
  
  def test_allowed_if_no_robots
    assert @robots.allowed?("http://www.yahoo.com")
  end
  
  def test_reddit
    assert @robots.allowed?("http://reddit.com")
  end
  
  def test_other
    assert @robots.allowed?("http://www.yelp.com/foo")
    assert !@robots.allowed?("http://www.yelp.com/mail?foo=bar")
  end
  
  def test_site_with_disallowed
    assert @robots.allowed?("http://www.google.com/")
  end
  
  def test_other_values
    sitemap = {"Sitemap" => "http://www.eventbrite.com/sitemap_index.xml"}
    assert_equal(sitemap, @robots.other_values("http://eventbrite.com"))
  end
end