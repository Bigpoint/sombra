# encoding: UTF-8
# frozen_string_literal: true

##
# A helper controller.
# It ensures that the user is authenticated before accessing a controller.
# Other controllers inherite from this controller.
class SecuredController < ApplicationController
  before_action :authenticate_user
end
