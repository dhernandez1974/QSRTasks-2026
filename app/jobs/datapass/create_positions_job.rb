class Datapass::CreatePositionsJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordInvalid

  def perform(organization_id)
    organization = Organization.where(id: organization_id).first if organization_id.present?
    return unless organization.present?
    Datapass::EmployeeDetail.where(organization_id: organization.id).each do |record|
      Datapass::JtcPosition.find_or_create_by(jtc: record.jtc, job_title: record.primary_job_title)
    end
  end
end
