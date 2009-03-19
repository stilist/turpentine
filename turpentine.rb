#!/usr/bin/ruby

# A simple Twitter client.
#
# Usage:
# ./turpentine.rb
#
# Code is provided under the MIT license. See LICENSE for details.

require 'rubygems'
require 'json'
require 'net/http'
require 'open-uri'
require 'uri'
require 'yaml'

# Config

CONFIG = YAML::load(File.read('config.yaml'))
$user = CONFIG['user']
$password = CONFIG['password']

puts "#{$user} | #{$password}"
