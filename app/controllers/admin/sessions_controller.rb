class Admin::SessionsController < ActiveAdmin::Devise::SessionsController
  skip_before_action :enforce_2sv
end
