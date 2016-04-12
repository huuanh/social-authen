Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'M8hfjCQ2Y9r2UV1XcqYUJW3ip' , 'yW32gyfCgmSUvj9BI7vmZ80lA5RP9JikctiHJAotHfK5AxYPtN'
  provider :facebook, '556529944520835', 'ee278366cabc40268604c691a00fa13e'
           # scope: 'public_profile', info_fields: 'id,name,link'
  provider :google_oauth2, '695794795645-3ituo8fdkmjrpnoqnclk2ml9g4pobtdi.apps.googleusercontent.com', '-pQsEQlJ4V-MvrKB0zQ6RMCg',
           # scope: 'profile', image_aspect_ratio: 'square', image_size: 48, access_type: 'offline'
           scope: 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/drive.readonly'
  provider :wechat, 'wx429bc0ced9c00daa', '2999413fa2ffb134395e70d5d841ba33'
end