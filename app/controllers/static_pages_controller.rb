class StaticPagesController < ApplicationController
  def welcome
  	if current_user and current_user.token
	  	client = Foursquare2::Client.new(:oauth_token => current_user.token, :api_version => '20120609')
	  	venue_history = client.user_venue_history(options = {}).items

	  	@map_hash = Gmaps4rails.build_markers(venue_history) do |venue, marker|
			  marker.lat venue.venue.location.lat
			  marker.lng venue.venue.location.lng
			  marker.infowindow venue.venue.name
			end

			@photo = client.user_photos(options = {})
	  end
  end
end
