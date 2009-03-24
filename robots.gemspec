Gem::Specification.new do |s|
  s.name     = "robots"
  s.version  = "0.7.1"
  s.date     = "2008-12-10"
  s.summary  = "Simple robots.txt parser"
  s.email    = "kyle@kylemaxwell.com"
  s.homepage = "http://github.com/fizx/robots"
  s.description = "It parses robots.txt files"
  s.has_rdoc = true
  s.authors  = ["Kyle Maxwell", "Sausheong Chang"]
  s.files    = ["README", "lib/robots.rb"]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
  s.add_dependency("fizx-loggable", ["> 0.0.0"])
end
