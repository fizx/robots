require "open-uri"
require "uri"
require "rubygems"

class Robots
  
  class ParsedRobots
    
    def initialize(uri)
      @last_accessed = Time.at(1)
      io = open(URI.join(uri.to_s, "/robots.txt")) rescue nil
      if !io || io.content_type != "text/plain" || io.status != ["200", "OK"]
        io = StringIO.new("User-agent: *\nAllow: /\n")
      end

      @other = {}
      @disallows = {}
      @allows = {}
      @delays = {} # added delays to make it work
      agent = /.*/
      io.each do |line|
        next if line =~ /^\s*(#.*|$)/
        arr = line.split(":")
        key = arr.shift
        value = arr.join(":").strip
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
        when "Crawl-delay"
          @delays[agent] = value.to_i
        else
          @other[key] = value
        end
      end
      
      @parsed = true
    end
    
    def allowed?(uri, user_agent)
      return true unless @parsed
      allowed = true
      path = uri.request_uri
      
      @disallows.each do |key, value|
        if user_agent =~ key
          value.each do |rule|
            if path =~ rule
              allowed = false
            end
          end
        end
      end
      
      @allows.each do |key, value|
        unless allowed      
          if user_agent =~ key
            value.each do |rule|
              if path =~ rule
                allowed = true
              end
            end
          end
        end
      end
      
      if allowed && @delays[user_agent]
        sleep @delays[user_agent] - (Time.now - @last_accessed)
        @last_accessed = Time.now
      end
      
      return allowed
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
  
  def other_values(uri)
    uri = URI.parse(uri.to_s) unless uri.is_a?(URI)
    host = uri.host
    @parsed[host] ||= ParsedRobots.new(uri)
    @parsed[host].other_values
  end
end
