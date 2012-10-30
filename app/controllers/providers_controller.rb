class ProvidersController < ApplicationController
  
  before_filter :redirect, :only => [:show, :edit]

  def login
    redirect_to "/auth/#{params[:auth_type]}"
  end
  
  def new
    session[:badge] == params[:badge]
    redirect_to "/auth/#{params[:auth_type]}"
  end
  
  def voted
    redirect_to root_url if !current_user
    session[:badge]= "ivoted_banner"
    current_user.update_attributes(:voted=> true)
    @photo = current_provider.photos.last
    render "photos/new"
  end
  
  def index
    render "providers/index"
  end
  
  def show
    render "providers/show"
  end

  def edit
    @post = Post.new
    render "providers/edit"
  end
  
  def update
    current_provider.update_attributes(:name=> params[:provider][:name]) if !params[:provider][:name].blank?
    if current_user.update_attributes(params[:user])
      flash[:notice] = PROFILE_UPDATED
      redirect_to "/#{current_provider.provider_type}/#{current_provider.uuid}"
    else
      flash[:notice] = current_user.errors.full_messages.to_sentence
      redirect_to :back
    end
  end
  
  def redirect
    redirect_to root_url if !@user
  end

end