task :default do
  system "gem build robots.gemspec"
  system "sudo gem uninstall robots"
  system "sudo gem install robots"
end

task :test do
  load "test/test_robots.rb"
end