#!/usr/bin/ruby -w

require 'rubygems'; require 'cgi'; require 'yaml'
require 'authenticate'; require 'engine'; require 'twitter'


# configuration is done entirely through config.yaml
CONFIG_FILE = 'config.yaml'

if File.exist?(CONFIG_FILE) && File.ftype(CONFIG_FILE) == 'file'
  CONFIG = YAML::load(File.read('config.yaml'))
else
  abort "\n\nPlease edit config-example.yaml and save it as config.yaml\n\n"
end


DEBUG_MODE = false
# don't check in more than once every three minutes
UPDATE_EVERY = CONFIG['update_every'] < 3 ? 3 : CONFIG['update_every']

AUTH_MODE = CONFIG['auth_mode']
if AUTH_MODE == 'basic'
  # OAuth mode automatically gets these gems from twitter_oauth.
  require 'json'; require 'rest-open-uri'
elsif AUTH_MODE == 'oauth'
  require 'twitter_oauth'
else
  abort 'Invalid authentication mode. You must use basic or oauth.'
end


# engines on!
$turp = Engine.new

if ARGV[0] == 'out'
  until 1 == 2
    print '> '
    status = STDIN.gets.chomp!

    $turp.post_new_status(status) unless status.empty?

    puts
  end
else
  until 1 == 2
    since_id = $turp.get_all_timelines(since_id)
    sleep(UPDATE_EVERY * 60)
  end
end
