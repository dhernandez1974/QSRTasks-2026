class IdmgmtJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Store.find_by(number: nsn.to_i)
    data["people"].each do |id|
      Idmgmt.find_or_create_by(geid: id['person']['ids'][1]['value']) do |user|
        user.update(
          modified_date: Date.strptime(id['person']['modified'], '%Y%m%d'),
          nsn: store.number, first_name: id['person']['first_name'],
          last_name: id['person']['last_name'],
          middle_initial: id['person']['middle_initial'],
          email: id['person']['email'],
          org_start_date: Date.strptime(id['person']['organization_start_date'], '%Y%m%d'),
          org_termination_date: id['person']['organization_termination_date'].nil? ? "" : Date.strptime(id['person']['organization_termination_date'], '%Y%m%d'),
          termination_code: id['person']['TerminationCode'],
          payroll_id: id['person']['ids'][0]['value'],
          geid: id['person']['ids'][1]['value'],
          jtc_primary: id['person']['jtcs'][0]['code'],
          jtc_p_start_date: Date.strptime(id['person']['jtcs'][0]['start_date'], '%Y%m%d'),
          jtc_p_end_date: id['person']['jtcs'][0]['end_date'].nil? ? "" : Date.strptime(id['person']['jtcs'][0]['end_date'], '%Y%m%d'),
          jtc_type_p: id['person']['jtcs'][0]['type'],
          phone: id['person']['phones'][0]['value'] )
      end
    end
  end

end
