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
    timeline = get('friends_timeline',
                 newest_status.nil? ? '' : "since_id=#{newest_status}").reverse
                 # newest_status is empty when we first start
                 # Reverse the timeline so new tweets are on the bottom

    statuses = ''
    timeline.map { |status|
      user = status['user']
      time = Date.parse(status['created_at']).strftime('%l:%M %p')

      statuses += "#{status['text']}\n-- #{user['name']} (#{time})\n\n"
    }
    puts statuses

    call_status = get('rate_limit_status', '', 'account')
    call_limit = call_status['hourly_limit']
    calls_left = call_status['remaining_hits']
    puts "(#{calls_left}/#{call_limit} API calls remaining for the hour)\n\n"

    # Return the id of the first (most recent) status
    # This will passed back in as newest_status
    return timeline.first['id']
  end

  def update(status)
    return post('update', "status=#{status}")
  end


  # The machinery that runs it all
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
  def get(api_method, data = '', kind = 'statuses')
    begin
      response = open("#{BASE_URL}/#{kind}/#{api_method}.json",
                      :http_basic_authentication => [USER, PASSWORD],
                      :body => data).read
      return JSON.parse(response)
    rescue OpenURI::HTTPError => error_code
      error(error_code)
    end
  end
  def post(api_method, data, kind = 'statuses')
    begin
      response = open("#{BASE_URL}/#{kind}/#{api_method}.json",
                      :http_basic_authentication => [USER, PASSWORD],
                      :method => :post,
                      :body => data).read
      return JSON.parse(response)
    end
  end
end


$turp = Turpentine.new

# this loop will run until interrupted
until 1==2
  newest_status = $turp.friends_timeline(newest_status)

  # three minutes, to make sure we don't hit the limit
  sleep(180)
end
