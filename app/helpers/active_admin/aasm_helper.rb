module ActiveAdmin::AasmHelper
module_function

  def buttons(resource, view)
    resource.aasm.permitted_transitions.each do |transition|
      event = transition.fetch(:event).to_s

      view.item(
        event.humanize,
        view.send("#{event}_admin_#{resource.class.name.underscore}_path", resource),
        method: :post,
        data: { confirm: "Are you sure?" },
        class: "member_link #{event}_link",
      )
    end

    nil
  end

  def member_actions(resource_class, registration)
    resource_class.aasm.events.each do |event|
      registration.send(:member_action, event.name, method: :post) do
        resource.public_send("#{event.name}!")
        redirect_to(send("admin_#{resource_class.table_name}_path"),
          notice: "#{event.name.to_s.humanize} was successful",
        )
      end
    end

    nil
  end
end
