# encoding: UTF-8
# frozen_string_literal: true

##
# The AccessPolicy defines which users and roles are needed to access resources.
class AccessPolicy
  include AccessGranted::Policy

  def configure
    role :admin, proc { |user| user.admin? } do
      can :manage, User
    end

    role :application, proc { |user| user.application? } do
      can [:read, :update], User do |user, app|
        user.id == app.id
      end
    end
  end
end
