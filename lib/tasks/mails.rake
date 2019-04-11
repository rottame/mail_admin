task create_mails: :environment do 
  require 'csv'
  csv = CSV.parse(Rails.root.join('new_mails.csv').read)
  csv.each do | r |
    mbox = Mailbox.find_or_initialize_by(username: r[3].strip)
    if mbox.new_record?
      mbox.password = r[1].strip
      mbox.save!

      old = Mailbox.find_by(username: r[0].strip)
      if old
        fwds = Forward.where(origin: old.username).where(enabled: true)
        fwds.each{|f| f.update_attribute :enabled, false}

        dests = fwds.map(&:destinations).map{|d| d.split(/(,|\n)/)}.flatten.uniq
        dests << mbox.username

        fwds = Forward.where(origin: mbox.username).where(enabled: true)
        fwds.each{|f| f.update_attribute :enabled, false}

        dests += fwds.map(&:destinations).map{|d| d.split(/(,|\n)/)}.flatten.uniq

        dests = dests.uniq
        dests.reject!{|f| f.strip == old.username}
        dests.reject!{|f| f.strip.blank?}

        puts dests.inspect
        old.forwards.create!(destinations: dests.join(","), to_self: true, enabled: true)
      end
    end
  end
end
