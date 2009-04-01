#!/usr/bin/ruby -w

# Code is provided under the MIT license. See LICENSE for details.

class Engine
  def oauthorize
    consumer_key = CONFIG['oauth']['consumer_key']
    consumer_secret = CONFIG['oauth']['consumer_secret']
    request_token = CONFIG['oauth']['request_token']
    request_secret = CONFIG['oauth']['request_secret']

    if request_token.nil? && request_secret.nil?
      client = TwitterOAuth::Client.new(
           :consumer_key => consumer_key,
           :consumer_secret => consumer_secret
           )
      request_token = client.request_token

      puts "Please open the following address in your browser to authorize this application:"
      puts "#{request_token.authorize_url}\n"
  
      puts "Hit enter when you have completed authorization."
      STDIN.gets
  
      access_token = client.authorize(
          request_token.token,
          request_token.secret
      )
  
      File.open(CONFIG_FILE, 'w') do |out|
        CONFIG['oauth']['request_token'] = access_token.token
        CONFIG['oauth']['request_secret'] = access_token.secret
        YAML::dump(CONFIG, out)
      end
    else
      client = TwitterOAuth::Client.new(
        :consumer_key => consumer_key,
        :consumer_secret => consumer_secret,
        :token => request_token,
        :secret => request_secret
      )
    end

    return client
  end

  def timeline(newest_status)
    twitter = Twitter.new

    friends = twitter.friends_timeline(newest_status)

    # don't show @replies older than the oldest update in the friends timeline
    newest_status = friends.first['id'] if !friends.empty? && newest_status.nil?
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
    data.map do |status|
      user = status['user']
      time = DateTime.parse(status['created_at']).strftime('%l:%M %p')
      text = CGI.unescape(status['text'])

      text = decorator.empty? ? text : text.insert(0, "#{decorator} ")
      text.insert(80, "\n#{decorator} ") if data.length >= 80

      timeline += "#{text}\n-- #{user['name']} (@#{user['screen_name']}) at #{time}\n\n"
    end

    return timeline
  end
end
