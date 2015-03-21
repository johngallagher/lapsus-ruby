running_in_plain_old_ruby = defined? Bacon
if running_in_plain_old_ruby
  path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'models'))
  $LOAD_PATH.unshift(path)
  require "ostruct"
  require "pathname"
  require 'time'
  require 'facon'
end
