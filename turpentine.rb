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

class Twitter
  def friends_timeline(newest_status)
    # newest_status is empty when we launch
    since = newest_status.nil? ? '' : "since_id=#{newest_status}"
    return api_call('friends_timeline', since)
  end

  def at_replies(newest_status)
    return api_call('replies', "since_id=#{newest_status}")
  end

  # The machinery that runs it all
  def api_call(api_method, query_in = '', verb = 'get', api_type = 'statuses')
    begin
      query = "?#{query_in}" unless query_in.empty?
      query += "&source=Turpentine" if verb == 'post'

      # debugging
#     puts " * * * #{api_method}?#{query}"

      response = open("#{BASE_URL}/#{api_type}/#{api_method}.json#{query}",
                      :http_basic_authentication => [USER, PASSWORD],
                      :method => verb.to_sym).read
      return JSON.parse(response)
    rescue OpenURI::HTTPError => error_code
      Turpentine.error(error_code)
    end
  end 
end

class Turpentine
  def timeline(newest_status)
    twitter = Twitter.new

    friends = twitter.friends_timeline(newest_status)

    # don't show @replies older than the oldest update in the friends timeline
    newest_status = friends.first['id'] if !friends.empty? and newest_status.nil?
    replies = twitter.at_replies(newest_status)

    # merge everything to eliminate duplicates
    timeline = friends | replies
    puts format(timeline.reverse, '')

    # return the id of the most recent timeline item
    # if there are no new statuses, send back the one we came in with
    return friends.empty? ? newest_status : friends.first['id']
  end

  def update(status)
    twitter = Twitter.new
    status = CGI.escape(status)
    twitter.api_call('update', "status=#{status}", 'post')
  end

  def format(data, decorator)
    timeline = ''
    data.map { |status|
      user = status['user']
      time = DateTime.parse(status['created_at']).strftime('%l:%M %p')
      text = CGI.unescape(status['text'])

      text = decorator.empty? ? text : text.insert(0, "#{decorator} ")
      text.insert(80, "\n#{decorator} ") if data.length >= 80

      timeline += "#{text}\n-- #{user['name']} (@#{user['screen_name']}) at #{time}\n\n"
    }

    return timeline
  end

  def error(error_code)
    status_number = error_code.to_s.split(' ')[0]

    # Don't complain if there were no new statuses
    return if status_number == '300'

    puts "\n\nError: #{error_code}"
    if status_number == '400'
      warn "Uh-oh, something went wrong.\n\n"
    elsif status_number == '401'
      raise "Make sure the information in config.yaml is correct.\n\n"
      abort
    elsif status_number == '502'
      raise "Twitter is down.\n\n"
    elsif status_number == '503'
      raise "Twitter's running slowly.\n\n"
    end
  end
end

$turp = Turpentine.new

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

    last_update = Time.now.strftime('%l:%M %p')
    puts "** Checked in at #{last_update}\n\n"

    # three minutes, to make sure we don't hit the limit
    sleep(180)
  end
end
