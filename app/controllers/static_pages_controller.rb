class StaticPagesController < ApplicationController
  def welcome
  	if current_user and current_user.token
	  	client = Foursquare2::Client.new(:oauth_token => current_user.token, :api_version => '20120609')
	  	@venue_history = client.user_venue_history(options = {})
	  end
  end
end
