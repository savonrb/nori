require 'bundler'
Bundler.require :test

$:.unshift File.expand_path('../../lib', __FILE__)
require 'crack'
