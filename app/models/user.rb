class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:foursquare]

  #->Prelang (user_login/devise)
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    # The User was found in our database
    return user if user

    # Check if the User is already registered without Facebook
    user = User.where(email: auth.info.email).first

    return user if user

    # The User was not found and we need to create them
    User.create(name:     auth[:extra][:raw_info][:name],
                provider: auth.provider,
                uid:      auth.uid,
                email:    auth[:info][:email],
                password: Devise.friendly_token[0,20])
  end

  def self.find_for_foursquare_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first

    # The User was found in our database
    return user if user

    # Check if the User is already registered without Foursquare
    user = User.where(email: auth.info.email).first

    return user if user

    # The User was not found and we need to create them
    puts auth
    User.create(name:     auth[:extra][:raw_info][:name],
                provider: auth.provider,
                uid:      auth.uid,
                email:    auth[:info][:email],
                password: Devise.friendly_token[0,20],
                token:    auth[:credentials][:token])
  end

  def venue_history
    client = initilize_client
    if client != ""
      venue_history = client.user_venue_history(options = {}).items
      map_hash = Gmaps4rails.build_markers(venue_history) do |venue, marker|
        marker.lat venue.venue.location.lat
        marker.lng venue.venue.location.lng
        marker.infowindow venue.venue.name
      end
    else
      []
    end
  end

  def user_details
    client = initilize_client
    client.user(self.uid, options = {})
  end

  def profile_pic_url
    photo_hash = user_details.photo
    url = photo_hash.prefix+"original"+photo_hash.suffix
  end

  protected
  def initilize_client
    if self and self.token
      Foursquare2::Client.new(:oauth_token => self.token, :api_version => '20120609')
    else
      ""
    end
  end


end
