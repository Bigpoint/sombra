##
# The AccessPolicy defines which users and roles are needed to access resources.
class AccessPolicy
  include AccessGranted::Policy

  def configure
    role :admin, proc { |user| user.admin? } do
      can :manage, User
    end
  end
end
