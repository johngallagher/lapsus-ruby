# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'
require 'bubble-wrap'
require 'bubble-wrap/reactor'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'lapsus_menu_bar'
  app.frameworks += %W[ ApplicationServices ]
end
