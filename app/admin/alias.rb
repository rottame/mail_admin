ActiveAdmin.register Alias do
  menu priority: 1
  permit_params :origin, :destinations, :to_self, :enabled

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
    column :origin
    column :destinations
    column :to_self do | r |
      status_tag r.to_self.to_s
    end
    column :enabled do | r |
      status_tag r.enabled.to_s
    end
    actions dropdown: true do | r |
      item 'Abilita', enable_admin_alias_path(r) unless r.enabled
      item 'Disabilita', disable_admin_alias_path(r) if r.enabled
    end
  end

  filter :origin
  filter :destinations

  form do |f|
    f.inputs "Dettagli Alias" do
      f.input :origin
      f.input :to_self
      f.input :destinations, as: :text
      f.input :enabled
    end
    f.actions
  end

  show do
    attributes_table do
      row :origin
      row :destinations
      row :to_self do
        status_tag resource.to_self.to_s
      end
      row :enabled do
        status_tag resource.enabled.to_s
      end
    end
    active_admin_comments
  end
end
