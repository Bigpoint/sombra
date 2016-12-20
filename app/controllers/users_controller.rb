# encoding: UTF-8
# frozen_string_literal: true

##
# The UsersController handles REST logic for the User resource.
# Actions:
#   * index
#   * show
#   * create
#   * update
#   * destroy
class UsersController < SecuredController
  before_action :set_user, only: [:show, :update, :destroy]

  ##
  # Method to show all users.
  # @example GET /users
  def index
    authorize! :read, User
    @users = User.all

    render json: @users
  end

  ##
  # Method to show a particular user.
  # @example GET /users/5857...
  def show
    authorize! :read, User
    render json: @user
  end

  ##
  # Method to create a new user.
  # @example POST /users with body +{"user":{"name":"myapplication","password":"securePassword","role":"application"}}+
  def create
    authorize! :create, User
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  ##
  # Method to update a given user.
  # @example PUT /users/5857... with body +{"user":{"name":"renamedApplication"}}+
  def update
    authorize! :update, User
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  ##
  # Method to delete a give user.
  # @example DELETE /users/5857...
  def destroy
    authorize! :destroy, User
    @user.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(:name, :password, :role)
  end
end
