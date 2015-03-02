# -*- coding: utf-8 -*-
$LOAD_PATH.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/osx'
require 'bubble-wrap/reactor'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  app.name = 'lapsus'
  app.frameworks += %w(ApplicationServices)
  app.files += Dir.glob(File.dirname(__FILE__) + '/lib/**/*.rb')
  app.redgreen_style = :progress
end

MotionBundler.setup do |app|
  app.require 'ostruct'
  app.require 'pathname'
end
