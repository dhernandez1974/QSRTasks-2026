class LifelenzScheduleJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Store.find_by(number: nsn.to_i)
    return unless store

    puts "DATA: #{data}"

    data.each do |schedule_data|
      # Parse the schedule start date
      schedule_start_date = parse_date(schedule_data["ScheduleStartDate"])
      puts "SCHEDULE START DATE: #{schedule_start_date}"
      # Parse the labor start of day time
      labor_start_of_day = parse_time(schedule_data["LaborStartOfDay"])
      
      # Create or update the employee schedule record
      employee_schedule = EmployeeSchedule.find_or_create_by(
        store_id: store.id,
        nsn: schedule_data["NSN"],
        organization_id: store.organization.id,
        schedule_start_date: schedule_start_date
      ) do |rec|
        rec.update(
          status: schedule_data["Status"],
          school_in_session: schedule_data["SchoolInSession"],
          labor_start_of_week: schedule_data["LaborStartOfWeek"],
          labor_start_of_day: labor_start_of_day,
          organization_id: store.organization_id,
          schedule: schedule_data["Schedule"]
        )
      end
      
      # Only process shifts if status is "Posted" or "Approved"
      next unless ["Posted", "Approved"].include?(schedule_data["Status"])
      
      # Process each day's schedule and create employee shift records
      schedule_data["Schedule"]&.each do |day_schedule|
        # Get the schedule date from the Value array
        schedule_date = parse_date(day_schedule["Value"]&.first&.dig("ScheduleDate"))
        next unless schedule_date
        
        # Process each shift for this day
        day_schedule["Shifts"]&.each do |shift|
          EmployeeShift.find_or_create_by(
            employee_schedule_id: employee_schedule.id,
            geid: shift["GEID"],
            schedule_date: schedule_date,
            start_time: convert_time(schedule_date.to_s, shift["StartTime"])
          ) do |shift_record|
            shift_record.update(
              end_time: convert_time(schedule_date.to_s, shift["EndTime"]),
              jtc_type: shift["JTCType"],
              job_title_code: shift["JobTitleCode"],
              job_type: shift["JobType"],
              edit_history: shift["EditHistory"],
              symbols: shift["Symbols"]
            )
          end
        end
      end
    end
  end

  private

  def parse_date(date_string)
    return nil if date_string.nil? || date_string.empty?
    # Parse date in format "20260218" to Date object
    Date.strptime(date_string, "%Y%m%d")
  rescue ArgumentError
    nil
  end

  def parse_time(time_string)
    return nil if time_string.nil? || time_string.empty?
    # Parse time in format "04:00" to Time object in Central Time
    Time.zone.parse(time_string)
  rescue ArgumentError
    nil
  end

  def convert_time(date_string, time_string)
    # Parse date components: "2026-02-18"
    year, month, day = date_string.split('-').map(&:to_i)
    # Parse time components: "04:30:00" or "25:30:00" (hours can be >= 24)
    hour, minute = time_string.split(':').map(&:to_i)

    # Handle times beyond 24:00:00 (e.g., 25:30:00 = 1:30 AM next day)
    if hour >= 24
      adjusted_hour = hour % 24
      # Create DateTime with the base date, then add the extra days
      DateTime.new(year, month, day, adjusted_hour, minute)
    else
      # Create DateTime without timezone conversion
      DateTime.new(year, month, day, hour, minute)
    end
  end
end
