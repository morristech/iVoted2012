class SessionsController < ApplicationController
  
 # before_filter :log, :only => :create

  def destroy
    flash[:notice] = "You have signed out!"
    session[:user_id] = nil
    current_user = false
    redirect_to root_url
  end
  
  def create
    auth_hash[:provider] = auth_hash[:provider].split("_")[0]
    p_atts = {:provider_type => auth_hash[:provider], :uuid=> get_uuid}
    p_atts.merge!(:user_id => current_user.id) if current_user
    auth_hash.merge!(:badge_type => session[:badge]) if !session[:badge].nil?
    auth_hash.merge!(:email => session[:email]) if !session[:email].nil?
    provider = Provider.where(p_atts).first_or_create(:auth_hash=>auth_hash)
    provider.update_attributes(:auth_hash=>auth_hash)
    current_user = provider.user
    session[:user_id] = provider.user_id
    session[:provider] = auth_hash[:provider]
    session[:provider_uuid] = provider.uuid
    if provider.badge_type.match("sopa")
      sopa = "/sopa"
      msg = sopa_tweet
    else
      sopa = ""
      msg = default_tweet
    end
    if !session[:message].nil?
      msg = session[:message]
      session.delete(:message)
    end
    if session[:autotweet]
      provider.send_tweet(msg) rescue false
    end
    if current_user.i_voted_for_president.blank?
      redirect_to "/#{auth_hash[:provider]}/#{provider[:uuid]}#{sopa}/edit", :notice => badge_updated_text
    else
      redirect_to "/#{auth_hash[:provider]}/#{provider[:uuid]}#{sopa}", :notice => SIGNIN_NOTICE
    end
  end
  
  def failure
    delete_session
    redirect_to root_url, :notice => AUTHORIZATION_FAILED
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
  
  def get_uuid
    auth_hash = request.env['omniauth.auth']
    if auth_hash[:provider] == "twitter"
       id = auth_hash.extra.raw_info.screen_name
    else
       id = auth_hash.extra.raw_info.id
    end
    return id
  end

  
  def log
    Rails.logger.info auth_hash.inspect+"\n\n"
    Rails.logger.info "provider = #{auth_hash.provider}"
    Rails.logger.info "uuid = #{auth_hash.uuid}"
    Rails.logger.info "info = #{auth_hash.info}"
    Rails.logger.info "credentials = #{auth_hash.credentials}"
    Rails.logger.info "extra = #{auth_hash.extra}"
    data = auth_hash.extra.raw_info if !auth_hash.extra.raw_info.nil?
    #data = auth_hash.extra.user_hash if !auth_hash.extra.user_hash.nil?
    
    data.keys.each do |k|
      Rails.logger.info "#{k} = #{data[k]}"
    end
  end
  
end