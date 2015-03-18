ActiveAdmin.register Forward do
  menu priority: 1
  permit_params :origin, :destinations, :enabled, :to_self

  belongs_to :mailbox

  action_item :enable, only: :show, if: ->{ resource.disabled? } do
    link_to 'Abilita', enable_admin_alias_path(resource)
  end

  action_item :disable, only: :show, if: ->{ resource.enabled? }  do
    link_to 'Disabilita', disable_admin_alias_path(resource)
  end
  
  member_action :disable, method: :get do
    resource.update_attribute :enabled, false
    redirect_to :back, notice: :disabled
  end

  index do
    selectable_column
    column :destinations
    column :to_self do | r |
      status_tag r.to_self.to_s
    end
    column :enabled do | r |
      status_tag r.enabled.to_s
    end
    actions dropdown: true do | r |
      item 'Abilita', enable_admin_alias_path(r)     if r.disabled?
      item 'Disabilita', disable_admin_alias_path(r) if r.enabled?
    end
  end

  filter :origin
  filter :destinations

  form do |f|
    f.inputs "Dettagli Alias" do
      f.input :destinations, as: :text
      f.input :to_self
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

  controller do
    alias :build_resource_real :build_resource

    def build_resource
      res = build_resource_real
      res.origin = parent.username
      res
    end
  end
end
