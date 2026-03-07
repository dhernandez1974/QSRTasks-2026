class Datapass::EmployeeDetailsJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    payload = data.is_a?(String) ? JSON.parse(data) : data
    return if payload.nil?

    location = Location.find_by(number: nsn.to_i.to_s)
    if location.nil?
      puts "Location not found for NSN: #{nsn}"
      return
    end

    organization = location.organization

    payload.each do |employee_data|
      # GEID is often an integer in these files, but we store it as a string
      geid = employee_data["GEID"].to_s
      
      employee = Datapass::EmployeeDetail.find_or_initialize_by(geid: geid, organization_id: organization.id)

      employee.assign_attributes(
        location_id: location.id,
        primary_store_nsn: employee_data["Primary Store NSN"],
        gerid: employee_data["gerid"],
        payroll_id: employee_data["Payroll_ID"],
        eid: employee_data["EID"],
        first_name: employee_data["FirstName"],
        nick_name: employee_data["NickName"],
        last_name: employee_data["LastName"],
        primary_phone: employee_data["PrimaryPhone"]&.first,
        birth_date: employee_data["BirthDate"],
        email: employee_data["email"],
        jtc: employee_data["JTC"],
        primary_job_title: employee_data["Primary Job Title"],
        secondary_jtc: employee_data["Secondary JTC"],
        secondary_job_title: employee_data["Secondary Job Title"],
        employee_status: employee_data["EmployeeStatus"],
        reason: employee_data["Reason"],
        organization_start_date: parse_date(employee_data["Organization_Start_Date"]),
        organization_termination_date: parse_date(employee_data["Organization_Termination_Date"]),
        orientation_date: parse_date(employee_data["Orientation Date"]),
        first_punch_date: parse_date(employee_data["FirstPunchInDate"]),
        trailing_7_days_actual_hours_worked: employee_data["Trailing7Days_ActualHoursWorked"],
        trailing_4_weeks_actual_hours_worked: employee_data["Trailing4Weeks_ActualHoursWorked"],
        crew_trainer_trained: employee_data["CrewTrainerTrained"],
        crew_trainer_trained_date: parse_date(employee_data["CrewTrainerTrained_Date"]),
        shift_manager_trained: employee_data["ShiftManagerTrained"],
        shift_manager_trained_date: parse_date(employee_data["ShiftManagerTrained_Date"]),
        hu_graduate: employee_data["HU_Graduate"],
        graduation_date: parse_date(employee_data["GraduationDate"]),
        current_role_promotion_date: parse_date(employee_data["CurrentRolePromotionDate"]),
        shared_stores: employee_data["SharedStores"]
      )

      unless employee.save
        puts "Failed to save EmployeeDetail record for GEID #{geid}: #{employee.errors.full_messages.join(', ')}"
      end
    end
  end

  private

  def parse_date(date_str)
    return nil if date_str.blank?
    begin
      Date.strptime(date_str.to_s, "%Y%m%d")
    rescue Date::Error
      nil
    end
  end
end
