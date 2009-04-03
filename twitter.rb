#!/usr/bin/ruby -w

if __FILE__ == $0
  raise "\n\nThis file is not meant to be run standalone.\n\n"
end


# Process calls to the Twitter API.
class Twitter
  def api_call(api_method, query_string='', verb='get', api_type='statuses')
    puts " * * api_call('#{api_method}', '#{query_string}', '#{verb}', '#{api_type}')" if DEBUG_MODE == true

    begin
      query = query_string.empty? ? '' : "?#{query_string}"
      # Add on our client name if we're posting a new tweet via basic auth.
      query += '&source=Turpentine' if AUTH_MODE == 'basic' && verb == 'post'

      authentication = Authenticate.new

      if AUTH_MODE == 'basic'
        credentials = authentication.use_basic_auth

        response = open("http://twitter.com/#{api_type}/#{api_method}.json#{query}",
            :http_basic_authentication => [credentials['user'], credentials['password']],
            :method => verb.to_sym ).read

        result = JSON.parse(reponse)
      elsif AUTH_MODE == 'oauth'
        # XXX: This is horrible, but it works until I figure out the right way.

        credentials = authentication.use_oauth

        if api_method == 'friends_timeline'
          result = credentials.friends_timeline
        elsif api_method == 'replies'
          result = credentials.replies
        else
          result = []
        end
      end

      return result
    rescue OpenURI::HTTPError => error_message
      handle_error(error_message)
    end
  end

  def handle_error(error_message)
=begin
    error_code = error_message.split(' ')[0]
    error_explanation = #
=end
    puts error_message
  end
end
