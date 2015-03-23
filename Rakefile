# -*- coding: utf-8 -*-
$LOAD_PATH.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/osx'
require 'bubble-wrap/reactor'
require 'motion-stump'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end


Motion::Project::App.setup do |app|
  app.name = 'lapsus-ruby'
  app.frameworks += %w(ApplicationServices)
  app.files += Dir.glob(File.join(app.project_dir, 'app/**/*.rb'))
  app.files += Dir.glob(File.join(app.project_dir, 'lib/**/*.rb'))
  app.specs_dir = ['spec_motion']
end

MotionBundler.setup do |app|
  app.require 'ostruct'
  app.require 'pathname'
  app.require 'time'
  app.require 'uri/common'
  app.require 'uri/generic'
end
