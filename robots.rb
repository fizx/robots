require "open-uri"
require "uri"
class Robots
  class ParsedRobots
    def initialize(uri)
      io = open(URI.join(uri.to_s, "/robots.txt"))
      return if io.content_type != "text/plain"
      return if io.status != ["200", "OK"]

      @other = {}
      @disallows = {}
      @allows = {}
      agent = ""
      io.each do |line|
        next if line =~ /^\s*(#.*|$)/
        key, value = line.split(":")
        value.strip!
        case key
        when "User-agent":
          agent = to_regex(value)
        when "Allow":
          @allows[agent] ||= []
          @allows[agent] << to_regex(value)
        when "Disallow":
          @disallows[agent] ||= []
          @disallows[agent] << to_regex(value)
        else
          @disallows[key] ||= []
          @disallows[key] << value
        end
      end
      
      @parsed = true
    end
    
    def allowed?(uri, user_agent)
      return true unless @parsed
      allowed = true
      path = uri.request_uri
      puts "path: #{path}"
      
      @disallows.each do |key, value|
        if user_agent =~ key
          puts "matched #{key.inspect}"
          value.each do |rule|
            if path =~ rule
              puts "matched Disallow: #{rule.inspect}"
              allowed = false
            end
          end
        end
      end
      
      return true if allowed
      
      @allows.each do |key, value|
        if user_agent =~ key
          puts "matched #{key.inspect}"
          value.each do |rule|
            if path =~ rule
              puts "matched Allow: #{rule.inspect}"
              return true 
            end
          end
        end
      end
      
      return false
    end
    
    def other_values
      @other
    end
    
  protected
    
    def to_regex(pattern)
      pattern = Regexp.escape(pattern)
      pattern.gsub!(Regexp.escape("*"), ".*")
      Regexp.compile("^#{pattern}")
    end
  end
  
  def initialize(user_agent)
    @user_agent = user_agent
    @parsed = {}
  end
  
  def allowed?(uri)
    uri = URI.parse(uri.to_s) unless uri.is_a?(URI)
    host = uri.host
    @parsed[host] ||= ParsedRobots.new(uri)
    @parsed[host].allowed?(uri, @user_agent)
  end
end

if __FILE__ == $0
  require "test/unit"
  class RobotsTest < Test::Unit::TestCase 
    def test_robots
      robots = Robots.new "Ruby-Robot.txt Parser Test Script"
      assert robots.allowed?("http://www.yelp.com/foo")
      assert !robots.allowed?("http://www.yelp.com/mail?foo=bar")
    end
  end  
end
