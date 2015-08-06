class StaticPagesController < ApplicationController
  def welcome
  	if current_user and current_user.token
	  	@map_hash = current_user.venue_history
	  	@photo = current_user.profile_pic_url
	  end
  end
end
