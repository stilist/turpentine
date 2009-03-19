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

CONFIG = YAML::load(File.read('config.yaml'))
USER = CONFIG['user']
PASSWORD = CONFIG['password']
BASE_URL = 'http://twitter.com/statuses'

class Turpentine
  def friends_timeline(newest_status)
    if newest_status.nil?
      result = get('friends_timeline', '')
      newest_status = 0
    else
      result = get('friends_timeline', "since_id=#{newest_status}")
    end

    statuses = ''
    result.reverse.map { |status|
      user = status['user']
      time = Date.parse(status['created_at'], '%l:%i %p')

      statuses += "#{status['text']}\n-- #{user['name']} (#{time})\n\n"

      newest_status = status['id']
    }
    puts statuses

    return newest_status
  end

  def update(status)
    return post('update', "status=#{status}")
  end


  # The machinery that runs it all
  def get(api_method, data)
    response = open("#{BASE_URL}/#{api_method}.json",
                    :http_basic_authentication => [USER, PASSWORD],
                    :body => data).read
    return JSON.parse(response)
  end
  def post(api_method, data)
    response = open("#{BASE_URL}/#{api_method}.json",
                    :http_basic_authentication => [USER, PASSWORD],
                    :method => :post,
                    :body => data).read
    return JSON.parse(response)
  end
end


$turp = Turpentine.new

# this loop will run until interrupted
until 1==2
  newest_status = $turp.friends_timeline(newest_status)

  sleep(180) # three minutes
end
