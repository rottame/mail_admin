ActiveAdmin.register Mailbox do
  menu priority: 0
  permit_params do
    perm = [:password, :enabled, :password_confirmation]
    perm << :username if %w(new create).include?(params[:action])
    perm
  end

  action_item :aliases, only: :show do
    link_to 'Alias', admin_mailbox_forwards_path(resource)
  end

  action_item :enable, only: :show, if: ->{ resource.disabled? } do
    link_to 'Abilita', enable_admin_mailbox_path(resource)
  end

  action_item :disable, only: :show, if: ->{ resource.enabled? }  do
    link_to 'Disabilita', disable_admin_mailbox_path(resource)
  end

  action_item :new_random_password, only: :show  do
    link_to 'Password casuale', new_random_password_admin_mailbox_path(resource)
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
    resource.enabled = false
    if resource.save
      resource.fix_forwards!
      redirect_to :back, notice: :disabled
    else
      redirect_to :back, alert: resource.errors.full_messages.uniq.join(' ')
    end
  end

  member_action :new_random_password, method: :get do
    if resource.new_password!
      redirect_to :back, notice: :new_password_created
    else
      redirect_to :back, alert: resource.errors.full_messages.uniq.join(' ')
    end
  end

  index do
    selectable_column
    column :username
    column :password
    column :enabled do | r |
      status_tag r.enabled.to_s
    end
    actions dropdown: true do | r |
      item 'Alias', admin_mailbox_forwards_path(r)
      item 'Abilita', enable_admin_mailbox_path(r)     if r.disabled?
      item 'Disabilita', disable_admin_mailbox_path(r) if r.enabled?
      item 'Nuova password casuale', new_random_password_admin_mailbox_path(r)
    end
  end

  filter :username

  form do |f|
    f.inputs "Dettagli Mailbox" do
      f.input :username if resource.new_record?
      f.input :password, as: :String
      f.input :enabled
    end
    f.actions
  end

  show do
    attributes_table do
      row :username
      row :password
      row :enabled do
        status_tag resource.enabled.to_s
      end
    end
    active_admin_comments
  end
end
