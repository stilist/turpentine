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
  def timeline
    result = get('friends_timeline')

    statuses = ''

    result.map { |keys|
      user = keys['user']

      statuses += "#{keys['text']}\n-- #{user['name']}\n\n"
    }

    return statuses
  end

  def update(status)
    return post('update', "status=#{status}")
  end


  # The machinery that runs it all
  def get(api_method)
    response = open("#{BASE_URL}/#{api_method}.json",
                    :http_basic_authentication => [USER, PASSWORD]).read
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

turp = Turpentine.new

puts turp.timeline

print "> "
turp.update(STDIN.gets)
