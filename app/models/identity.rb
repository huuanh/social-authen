class Identity < ActiveRecord::Base
  belongs_to :user

  def from_omniauth(token, provider)
    identity = find_or_create_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
  end

  def access_token(token, provider)
    case self.provider
      when 'facebook'
        @graph = Koala::Facebook::API.new(token)
        profile = @graph.get_object('me?fields=id,name,about,age_range,birthday,email,gender,hometown,
          inspirational_people,devices,interested_in,education,languages,link,locale,location,meeting_for')

      when 'twitter'
        # Exchange our oauth_token and oauth_token secret for the AccessToken instance.
        access_token = prepare_access_token(self.token, self.token_secret)
        # use the access token as an agent to get the home timeline
        response = access_token.request(:get, 'https://dev.twitter.com/docs/api/1/get/account/verify_credentials')
        # response = access_token.request(:get, 'https://api.twitter.com/1.1/statuses/home_timeline.json')
        # response = access_token.request(:get, 'https://api.twitter.com/1.1/users/show.json')
        # response = access_token.request(:get, "http://api.twitter.com/1/statuses/user_timeline.json")
        puts response
        response.body

      when 'google_oauth2'
        token = self.token
        client = Google::APIClient.new
        client.authorization.access_token = token
        oauth2 = client.discovered_api('oauth2', 'v2')
        result = client.execute!(:api_method => oauth2.userinfo.get)
        JSON.parse(result.body)
      else
    end
  end

  private
  def prepare_access_token(oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new('M8hfjCQ2Y9r2UV1XcqYUJW3ip', 'yW32gyfCgmSUvj9BI7vmZ80lA5RP9JikctiHJAotHfK5AxYPtN', { :site => 'https://api.twitter.com'})

    # now create the access token object from passed values
    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
  end
end
