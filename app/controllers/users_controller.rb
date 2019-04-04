class UsersController < ApplicationController
  def index
    render plain: 'All the users!'
  end
end
