class EmployeeDetailsJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    data.each do |id|
      EmployeeDetail.find_or_create_by(geid: id['GEID']) do |user|
        user.update(
          nsn: id['Primary Store NSN'].to_i,
          payroll_id: id['Payroll_ID'],
          geid: id['GEID'],
          eid: id['EID'],
          first_name: id['FirstName'],
          last_name: id['LastName'],
          phone: id['PrimaryPhone'],
          email: id['email'],
          jtc: id['JTC'],
          secondary_jtc: id['Secondary JTC'],
          status: id['EmployeeStatus'],
          reason: id['Reason'],
          org_start_date: id['Organization_Start_Date'],
          org_end_date: id['Organization_Termination_Date'],
          orientation_date: id['Orientation Date'],
          first_punch_date: id['FirstPunchInDate'],
          trailing_7_day_hours: id['Trailing7Days_ActualHoursWorked'],
          trailing_4_week_hours: id['Trailing4Weeks_ActualHoursWorked'],
          crew_trainer_trained: id['CrewTrainerTrained'],
          crew_trainer_trained_date: id['CrewTrainerTrained_Date'],
          shift_manager_trained: id['ShiftManagerTrained'],
          shift_manager_trained_date: id['ShiftManagerTrained_Date'],
          hu_grad: id['HU_Graduate'],
          hu_grad_date: id['GraduationDate'])
      end
    end
  end


end
