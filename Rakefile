#!/usr/bin/env rake
# -*- coding: UTF-8 -*-

require 'rainbow/ext/string'

desc 'Run integration tests: foodcritic, rubocop, rspec'
task :build do
  # fail the build only for correctness
  puts "\nRunning foodcritic".color(:blue)
  sh 'foodcritic --chef-version 11.10 --tags ~FC001 --epic-fail correctness .'

  # check ruby syntax
  puts 'Running rubocop'.color(:blue)
  sh 'rubocop .'
end

task default: 'build'
