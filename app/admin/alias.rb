ActiveAdmin.register Alias do
  menu priority: 1
  permit_params :origin, :destinations, :enabled, :to_self

  action_item :enable, only: :show, if: ->{ resource.disabled? } do
    link_to 'Abilita', enable_admin_alias_path(resource)
  end

  action_item :disable, only: :show, if: ->{ resource.enabled? }  do
    link_to 'Disabilita', disable_admin_alias_path(resource)
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
    resource.update_attribute :enabled, false
    redirect_to :back, notice: :disabled
  end

  index do
    selectable_column
    column :origin
    column :destinations
    column :to_self do | r |
      if r.has_mailbox?
        status_tag r.to_self.to_s
      else
        text_node '-'
      end
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
      f.input :origin
      f.input :destinations, as: :text
      if resource.has_mailbox?
        f.input :to_self
      else
        f.input :to_self, as: :hidden, input_html: { value: 0 }
      end 
      f.input :enabled
    end
    f.actions
  end

  show do
    attributes_table do
      row :origin
      row :destinations
      if resource.has_mailbox?
        row :to_self do
          status_tag resource.to_self.to_s 
        end
      end
      row :enabled do
        status_tag resource.enabled.to_s
      end
    end
    active_admin_comments
  end
end
