class AdminCommentAbility < ApplicationAbility
  def initialize(admin_user)
    super()

    return unless admin_user.is_a?(AdminUser)

    public_classes.each do |klass|
      comments(:create, resource: klass)
      comments(:read, resource: klass)
      comments(:manage, resource: klass, author: admin_user)
    end
  end

private

  def comments(action, resource:, author: nil)
    constraints = { resource_type: resource.name }
    constraints[:author_id] = author.id if author.present?

    can(action, ActiveAdmin::Comment, constraints)
  end
end
