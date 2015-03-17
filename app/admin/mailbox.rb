ActiveAdmin.register Mailbox do
  menu priority: 0
  permit_params do
    perm = [:password, :enabled, :password_confirmation]
    perm << :username if %w(new create).include?(params[:action])
    perm
  end

  member_action :enable, method: :get do
    resource.enabled = true
    if resource.save
      redirect_to :back, notice: :enabled
    else
      redirect_to :back, alert: resource.errors.full_messages.uniq.join(' ')
    end
  end

  member_action :disable, method: :get do
    resource.update_attribute :false, true
    redirect_to :back, notice: :disabled
  end

  index do
    selectable_column
    column :username
    column :enabled do | r |
      status_tag r.enabled.to_s
    end
    actions dropdown: true do | r |
      item 'Abilita', enable_admin_alias_path(r) unless r.enabled
      item 'Disabilita', disable_admin_alias_path(r) if r.enabled
    end
  end

  filter :username

  form do |f|
    f.inputs "Dettagli Mailbox" do
      f.input :username if resource.new_record?
      f.input :password
      f.input :password_confirmation
      f.input :enabled
    end
    f.actions
  end

  show do
    attributes_table do
      row :username
      row :enabled do
        status_tag resource.enabled.to_s
      end
    end
    active_admin_comments
  end
end
