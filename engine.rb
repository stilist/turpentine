#!/usr/bin/ruby

# Code is provided under the MIT license. See LICENSE for details.

class Engine
  def consumer
    return OAuth::Consumer.new(CONFIG['oauth']['consumer_key'],
                               CONFIG['oauth']['consumer_secret'],
                               { :site => 'http://twitter.com' })
  end

  def timeline(newest_status)
    twitter = Twitter.new

    friends = twitter.friends_timeline(newest_status)

    # don't show @replies older than the oldest update in the friends timeline
    newest_status = friends.first['id'] if !friends.empty? and newest_status.nil?
    replies = twitter.at_replies(newest_status)

    # merge everything to eliminate duplicates
    timeline = friends | replies
    puts format(timeline.reverse, '') unless timeline.empty?

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
end
