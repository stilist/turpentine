#!/usr/bin/ruby -w

if __FILE__ == $0
  raise "\n\nThis file is not meant to be run standalone.\n\n"
end

class Engine
  # These two methods are the 'higher level interface' to the API-call method.
  def get_timeline(api_method, since_id)
    puts " * * get_timeline(#{api_method}, #{since_id})" if DEBUG_MODE == true

    since = since_id == 0 ? '' : "since_id=#{since_id}"
    twitter = Twitter.new
    twitter.api_call(api_method, since)
  end

  def post_new_status(status_text)
    puts " * * post_new_status('#{status_text}')" if DEBUG_MODE == true

    status = CGI.escape(status_text)
    twitter = Twitter.new
    twitter.api_call('update', "status=#{status}", 'post')
  end

  def get_all_timelines(since_id)
    puts " * * get_all_timelines(#{since_id})" if DEBUG_MODE == true

    # XXX: This since_id stuff is sloppy.
    since_id = 0 if since_id.nil?
    friends = get_timeline('friends_timeline', since_id)

    # If Turpentine has just launched, don't get mentions older than what's in
    # the friends timeline. (Also test if the friends timeline is empty,
    # because the user may not be following anyone.)
    since_id = friends.first['id'] if since_id == 0 && !friends.empty?
    mentions = get_timeline('replies', since_id)

    # Remove duplicates by unifying the timelines.
    merged_timeline = friends | mentions
    puts process(merged_timeline.reverse) unless merged_timeline.empty?

    since_id
  end

  # Clean up the data for display.
  def process(statuses)
    formatted_timeline = ''
    statuses.map do |status|
      user = status['user']
      time = DateTime.parse(status['created_at']).strftime('%l:%M %p')
      text = CGI.unescape(status['text'])

      formatted_timeline += "#{text}\n-- @#{user['screen_name']} at #{time}\n\n"
    end

    formatted_timeline
  end
end
