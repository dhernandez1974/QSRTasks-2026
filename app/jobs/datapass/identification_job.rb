class Datapass::IdentificationJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    emails = []
    count = 0
    data.each do |id|
      next if id['EmailAddress'].nil? || id['EmailAddress'].strip.downcase.empty?
      user = User.find_by(email: id['EmailAddress'].strip.downcase)
      if user.nil?
        count += 1
        emails << id['EmailAddress'].strip.downcase
      end
      next if user.nil?
      user.update(geid: id['GEID']) if user.geid.nil?
    end
    puts emails
    puts "The count of unfound emails is #{count}"
  end

end
