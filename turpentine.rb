#!/usr/bin/ruby -w

# A delightful Twitter/Ruby on Rails learning project.
#
# Usage:
#
# ./turpentine.rb
# ./turpentine.rb out
#
# Code is provided under the MIT license. See LICENSE for details.

require 'rubygems'
require 'yaml'

require 'engine'
require 'twitter'


# configuration is done entirely through config.yaml
CONFIG_FILE = 'config.yaml'

if File.exist?(CONFIG_FILE) && File.ftype(CONFIG_FILE) === 'file'
  CONFIG = YAML::load(File.read('config.yaml'))
else
  raise "\n\nPlease edit config-example.yaml and save it as config.yaml\n\n"
  abort
end

BASE_URL = 'http://twitter.com'
USER = CONFIG['basic_auth']['user']
PASSWORD = CONFIG['basic_auth']['password']
# don't check in more than once every three minutes
UPDATE_EVERY = CONFIG['update_every'] < 3 ? 3 : CONFIG['update_every']

if CONFIG['auth_mode'] == 'oauth'
  AUTH_MODE = 'oauth'
  # only load the gem if it's needed
  require 'twitter_oauth'
else
  AUTH_MODE = 'basic'
  # require'd by twitter_oauth
  require 'json'
  require 'rest-open-uri'
  # used to urlencode new tweets
  require 'cgi'
end


# engines on!
$turp = Engine.new

if ARGV[0] == 'out'
  until 1 == 2
    print '> '
    status = STDIN.gets.chomp!

    $turp.update(status) unless status.empty?

    puts
  end
else
  # this loop will run until interrupted
  until 1 == 2
    if AUTH_MODE == 'oauth'
      client = $turp.oauthorize

      puts client.friends_timeline
    else
      newest_status = $turp.timeline(newest_status)
    end
    
    sleep(UPDATE_EVERY * 60)
  end
end
