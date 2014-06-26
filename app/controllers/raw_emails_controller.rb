class RawEmailsController < ApplicationController
  
  def index
    @raw_emails = RawEmail.all
  end

  def show
    @raw_email = RawEmail.find(params[:id])
    @parsed_email = EmailParser::parse(@raw_email.raw_email)
  end

  def new
    @raw_email = RawEmail.new
  end

  def create
    @raw_email = RawEmail.new(params[:raw_email])
    if @raw_email.save
      redirect_to @raw_email, :notice => "Successfully created raw email."
    else
      render :action => 'new'
    end
  end

  def edit
    @raw_email = RawEmail.find(params[:id])
  end

  def update
    @raw_email = RawEmail.find(params[:id])
    if @raw_email.update_attributes(params[:raw_email])
      redirect_to @raw_email, :notice  => "Successfully updated raw email."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @raw_email = RawEmail.find(params[:id])
    @raw_email.destroy
    redirect_to raw_emails_url, :notice => "Successfully destroyed raw email."
  end
end
