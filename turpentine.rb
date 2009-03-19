#!/usr/bin/ruby

# A delightful Twitter/Ruby on Rails learning project.
#
# Usage:
# ./turpentine.rb
#
# Code is provided under the MIT license. See LICENSE for details.

require 'rubygems'
require 'json'
require 'rest-open-uri'
require 'yaml'

# Config
CONFIG_FILE = 'config.yaml'

if File.exist?(CONFIG_FILE) and File.ftype(CONFIG_FILE) === 'file'
  CONFIG = YAML::load(File.read('config.yaml'))
else
  raise "\n\nCouldn't find the configuration file.\nPlease edit config-example.yaml and save it as config.yaml\n\n"
end

USER = CONFIG['user']
PASSWORD = CONFIG['password']
BASE_URL = 'http://twitter.com'

class Turpentine
  def friends_timeline(newest_status)
    # newest_status is empty when we launch
    since = newest_status.nil? ? '' : "since_id=#{newest_status}"
    timeline = api_call('friends_timeline', since).reverse
    # Reverse the timeline so new tweets are on the bottom

    timeline.map { |status|
      user = status['user']
      time = DateTime.parse(status['created_at']).strftime('%l:%M %p')

      puts "#{status['text']}\n-- #{user['name']} (#{time}; #{status['id']})\n\n"
    }

    # return the id of the most recent status
    # if there are no new statuses, send back the one we came in with
    return timeline.empty? ? newest_status : timeline.last['id']
  end

  def update(status)
    return api_call('update', "status=#{status}", 'post')
  end


  def error(error_code)
    status_number = error_code.to_s.split(' ')[0]

    # Don't complain if there were no new statuses
    return if status_number == '300'

    puts "\n\nError: #{error_code}"
    if status_number == '400'
      raise "Uh-oh, something went wrong.\n\n"
    elsif status_number == '401'
      raise "Make sure the information in config.yaml is correct.\n\n"
      abort
    elsif status_number == '502'
      raise "Twitter is down.\n\n"
    elsif status_number == '503'
      raise "Twitter's running slowly.\n\n"
    end
  end

  # The machinery that runs it all
  def api_call(api_method, query = '', verb = 'get', api_type = 'statuses')
    verb = 'get' if verb == '' # this is lame
    begin
      query = "?#{query}" if !query.empty?

      # this previously used ':body => query', but that didn't seem to work
      response = open("#{BASE_URL}/#{api_type}/#{api_method}.json#{query}",
                      :http_basic_authentication => [USER, PASSWORD],
                      :method => verb.to_sym).read
      return JSON.parse(response)
    rescue OpenURI::HTTPError => error_code
      error(error_code)
    end
  end
end


$turp = Turpentine.new

# this loop will run until interrupted
until 1==2
  newest_status = $turp.friends_timeline(newest_status)

  # three minutes, to make sure we don't hit the limit
  sleep(180)
  puts "** Checked!\n\n"
end
