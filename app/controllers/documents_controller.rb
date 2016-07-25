class DocumentsController < ApplicationController

  def index
    puts "index"
    @uploads = Upload.where(user: current_user)
  end

end
