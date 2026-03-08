class Datapass::LifelenzPayperiodJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Store.find_by(number: nsn.to_i)
    return unless store

    # The data might be a string (if it's the Ruby-style pseudo-JSON) or a pre-parsed array
    if data.is_a?(String)
      begin
        data = eval(data)
      rescue => e
        puts "Error parsing data string: #{e.message}"
        return
      end
    end

    return unless data.is_a?(Array)

    data.each do |pp_data|
      # Create or update PayPeriod
      pay_period = PayPeriod.find_or_initialize_by(
        pay_period_identifier: pp_data["PayPeriodIdentifier"],
        store_id: store.id,
        organization_id: store.organization_id
      )

      pay_period.assign_attributes(
        start: parse_date(pp_data["Start"]),
        end: parse_date(pp_data["End"]),
        status: pp_data["Status"],
        posted_date: parse_date(pp_data["PostedDate"]),
        approved_date: parse_date(pp_data["ApprovedDate"]),
        diff_pay_rules: pp_data["DiffPayRules"],
        pay_period_total: pp_data["PayPeriodTotal"],
        employee_total: pp_data["EmployeeTotal"],
        labor_weeks: pp_data["LaborWeeks"],
        week_identifier: pp_data["WeekIdentifier"]
      )
      pay_period.save!

      # Process ActualEmployeeShift records
      pp_data["LaborWeeks"]&.each do |week|
        week["LaborDays"]&.each do |day|
          day["Employees"]&.each do |emp|
            next unless emp["UniqueShiftIdentifier"]

            shift = ActualEmployeeShift.find_or_initialize_by(
              unique_shift_identifier: emp["UniqueShiftIdentifier"],
              store_id: store.id,
              organization_id: store.organization_id
            )

            shift.assign_attributes(
              geid: emp["GEID"],
              payroll_id: emp["PayrollID"],
              work_type: emp["Type"],
              time_card_number: emp["TimeCardNumber"],
              job_title_code: emp["JobTitleCode"],
              pay_rate: emp["PayRate"]&.to_s,
              pay: emp["Pay"],
              punch: emp["Punch"]
            )
            shift.save!
          end
        end
      end
    end
  end

  private

  def parse_date(date_string)
    return nil if date_string.nil? || (date_string.is_a?(String) && date_string.empty?)
    return date_string if date_string.is_a?(Date) || date_string.is_a?(Time) || date_string.is_a?(DateTime)

    # Format is usually YYYYMMDD
    Date.strptime(date_string.to_s, "%Y%m%d")
  rescue ArgumentError
    nil
  end
end
