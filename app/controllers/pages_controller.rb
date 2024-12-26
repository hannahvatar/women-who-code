class PagesController < ApplicationController
  #skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def terms
  end

  def privacy
  end

  def refund
  end

  def shipping
  end

  def disclaimer
  end

  def intellectual_property
  end

  def size_guide
  end

  def contact
  end

  def create_contact
    # Handle the form submission
    # This will be called when the form is submitted
    flash[:notice] = "Thank you for your message. We will get back to you soon!"
    redirect_to contact_path
  end
end
