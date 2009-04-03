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
      query += '&source=Turpentine' if AUTH_MODE == 'basic' && verb == 'post'
      # Add on the client name if we're posting a new tweet via basic auth.

      authenticate = Authenticate.new

      if AUTH_MODE == 'basic'
        credentials = authenticate.use_basic_auth

        puts " * * /#{api_type}/#{api_method}.json#{query} [#{verb}]" if DEBUG_MODE == true

        response = open("http://twitter.com/#{api_type}/#{api_method}.json#{query}",
            :http_basic_authentication => [credentials['user'], credentials['password']],
            :method => verb.to_sym ).read
      else
        # XXX: Dunno how to handle this yet; will likely involve use of
        # twitter_oauth's returned object.
      end

      return JSON.parse(response)
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
