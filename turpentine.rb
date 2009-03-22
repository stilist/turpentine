#!/usr/bin/ruby

# A delightful Twitter/Ruby on Rails learning project.
#
# Usage:
#
# ./turpentine.rb
# ./turpentine.rb out
#
# Code is provided under the MIT license. See LICENSE for details.

require 'rubygems'
require 'json'
require 'rest-open-uri'
require 'yaml'
require 'cgi'
require 'oauth'

require 'engine'
require 'twitter'

# Config
CONFIG_FILE = 'config.yaml'

if File.exist?(CONFIG_FILE) and File.ftype(CONFIG_FILE) === 'file'
  CONFIG = YAML::load(File.read('config.yaml'))
else
  raise "\n\nCouldn't find the configuration file.\nPlease edit config-example.yaml and save it as config.yaml\n\n"
end

BASE_URL = 'http://twitter.com'
USER = CONFIG['basic_auth']['user']
PASSWORD = CONFIG['basic_auth']['password']
# don't check in more than once every three minutes
UPDATE_EVERY = CONFIG['update_every'] < 3 ? 3 : CONFIG['update_every']

$turp = Engine.new

if ARGV[0] == 'out'
  until 1 == 2
    print '> '
    status = STDIN.gets.chomp!

    if status.empty?
    elsif status == 'quit'
      puts "\n\n Bye-bye!\n\n"
      abort
    else
     $turp.update(status)
    end
    puts
  end
else
  # this loop will run until interrupted
  until 1 == 2
    newest_status = $turp.timeline(newest_status)

    sleep(UPDATE_EVERY * 60)
  end
end
