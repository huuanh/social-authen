class User < ActiveRecord::Base
  # has_many identities
  has_secure_password
  before_save { self.email = email.downcase }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, presence:true, length: { minimum: 6 }

  class << self
    def from_omniauth(provider, token, secret)
      auth_find_or_create_by(provider, token, secret)
    end
    def auth_find_or_create_by(provider, token, secret)
      identity = Identity.where(provider: provider, accesstoken: token)
      # debugger

      if identity.count > 0
        identity.first.user
      else
        access_token(provider, token, secret)
      end
    end

    def create_authentication(profile, provider, token, secret)
      if User.where(email: profile['email']).empty?
        user = User.new
        user.name = profile['name']
        user.email = profile['email']
        user.password = '123456789'
        user.password_confirmation = '123456789'
        user.save
      else
        user = User.where(email: profile['email']).first
      end
      identity = Identity.new
      identity.user = user
      identity.provider = provider
      identity.accesstoken = token
      identity.refreshtoken = secret
      identity.uid = profile['id']
      identity.name = profile['name']
      identity.email = profile['email']
      # identity.image = profile['']
      identity.url = profile['link']
      identity.save
      user
    end

    def prepare_access_token(oauth_token, oauth_token_secret)
      consumer = OAuth::Consumer.new('M8hfjCQ2Y9r2UV1XcqYUJW3ip', 'yW32gyfCgmSUvj9BI7vmZ80lA5RP9JikctiHJAotHfK5AxYPtN', { :site => 'https://api.twitter.com', :scheme => :header})
      request_token = consumer.get_request_token
      request_token.authorize_url
      puts '==============='
      puts request_token.token, request_token.secret

      # now create the access token object from passed values
      token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
      access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
    end

    def access_token(provider, token, secret)
      case provider
        when 'facebook'
          @graph = Koala::Facebook::API.new(token)
          profile = @graph.get_object('me?fields=id,name,about,birthday,email,gender,hometown,
          devices,education,languages,link,locale,location')
          # puts profile
          # debugger
          if Identity.where(provider: provider, uid: profile['id']).empty?
            create_authentication(profile, provider, token, secret)
          else
            Identity.where(provider: provider, uid: profile['id']).first.user
          end

        when 'twitter'
          consumer = OAuth::Consumer.new('M8hfjCQ2Y9r2UV1XcqYUJW3ip', 'yW32gyfCgmSUvj9BI7vmZ80lA5RP9JikctiHJAotHfK5AxYPtN', { :site => 'https://api.twitter.com', :scheme => :header})
          request_token = consumer.get_request_token
          # request_token.authorize_url
          puts '==============='
          puts request_token.token, request_token.secret

          # now create the access token object from passed values
          token_hash = { :oauth_token => token, :oauth_token_secret => secret }
          access_token = OAuth::AccessToken.from_hash(consumer, token_hash )

          # Exchange our oauth_token and oauth_token secret for the AccessToken instance.
          # use the access token as an agent to get the home timeline
          response = access_token.request(:get, 'https://dev.twitter.com/docs/api/1/get/account/verify_credentials')
          # response = access_token.request(:get, 'https://api.twitter.com/1.1/statuses/home_timeline.json')
          # response = access_token.get('https://api.twitter.com/1.1/users/show.json')
          # response = access_token.request(:get, "http://api.twitter.com/1/statuses/user_timeline.json")
          puts '-=-=-=-=-=-=-=-='
          puts response.body
          puts access_token
          User.new

        when 'google_oauth2'
          # token = self.token
          client = Google::APIClient.new
          client.authorization.access_token = token
          oauth2 = client.discovered_api('oauth2', 'v2')
          result = client.execute!(:api_method => oauth2.userinfo.get)
          profile = JSON.parse(result.body)
          if Identity.where(provider: provider, uid: profile['id']).empty?
            create_authentication(profile, provider, token, secret)
          else
            Identity.where(provider: provider, uid: profile['id']).first.user
          end
        else
      end
    end
  end
end
