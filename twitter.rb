#!/usr/bin/ruby

# Code is provided under the MIT license. See LICENSE for details.

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
#     puts " * * * #{api_method}#{query}"

      # default to basic auth
      unless AUTH_MODE == 'oauth'
        response = open("#{BASE_URL}/#{api_type}/#{api_method}.json#{query}",
                        :http_basic_authentication => [USER, PASSWORD],
                        :method => verb.to_sym).read
      else
      end

      return JSON.parse(response)
    rescue OpenURI::HTTPError => error_code
      puts error_code
    end
  end 
end