#!/usr/bin/ruby -w

if __FILE__ == $0
  raise "\n\nThis file is not meant to be run standalone.\n\n"
end


# A unified authentication method.
#
# If AUTH_MODE is set to 'basic', this will return a hash with the username
# and password.
# If AUTH_MODE is set to 'oauth', it will return twitter_oauth's object.
class Authenticate
  def use_oauth
    credentials = CONFIG['oauth']

    # Make sure the application has been registered with Twitter.
    if credentials['consumer_key'].nil? || credentials['consumer_secret'].nil?
      abort 'Please register your application with Twitter and edit config.yaml'
    end

    # If the OAuth process has not been completed we'll need to authorize.
    if credentials['request_token'].nil? || credentials['request_secret'].nil?
      oauth_client = TwitterOAuth::Client.new(
           :consumer_key => credentials['consumer_key'],
           :consumer_secret => credentials['consumer_secret'] )
      request_token = oauth_client.request_token

      puts "Please open the following address in your browser to authorize this application:"
      puts "#{request_token.authorize_url}\n"
      puts "Hit enter when you have completed authorization."
      STDIN.gets

      access_token = oauth_client.authorize(
          request_token.token,
          request_token.secret )

      # Update the config file with our completed authorization.
      File.open(CONFIG_FILE, 'w') do |out|
        CONFIG['oauth']['request_token'] = access_token.token
        CONFIG['oauth']['request_secret'] = access_token.secret
        YAML::dump(CONFIG, out)
      end
    # The user has already authorized this application.
    else
      oauth_client = TwitterOAuth::Client.new(
          :consumer_key => credentials['consumer_key'],
          :consumer_secret => credentials['consumer_secret'],
          :token => credentials['request_token'],
          :secret => credentials['request_secret'] )
    end

    return oauth_client
  end

  def use_basic_auth
    credentials = CONFIG['basic_auth']

    {'user' => credentials['user'],
     'password' => credentials['password'] }
  end
end
