class Datapass::InvyDtservtimesJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Store.find_by(number: nsn.to_i)
    data["data"].each do |dt|
      Dtservtime.find_or_create_by(matcher: store.id.to_s + '-' + dt[1] + '-' + dt[2]) do |rec|
        rec.update(
          store_id: store.id,
          bus_date: dt[1],
          qtr_hr_end_time: convert_time(dt[1], dt[2]),
          qtr_hr_ord_tim: dt[3],
          qtr_hr_lin1_tim: dt[4],
          qtr_hr_win1_tim: dt[5],
          qtr_hr_ovr_w1_cnt: dt[6],
          qtr_hr_win2_tim: dt[7],
          qtr_hr_ovr_w2_cnt: dt[8],
          qtr_hr_pk_cars_qty: dt[9],
          qtr_hr_pk_cars_tim: dt[10],
          qtr_hr_dt_trns_qty: dt[11],
          qtr_hr_order_tim: dt[12],
          qtr_hr_assem_tim: dt[13],
          qtr_hr_cash_tim: dt[14],
          qtr_hr_fc_svc_tim: dt[15],
          qtr_hr_fc_trns_qty: dt[16],
          qtr_hr_store_tim: dt[17],
          qtr_hr_store_qty: dt[18],
          ord_seconds: dt[11] * dt[3],
          lin1_seconds: dt[11] * dt[4],
          win1_seconds: dt[11] * dt[5],
          win2_seconds: dt[11] * dt[7],
          pk_seconds: dt[9] * dt[10],
          fc_order_seconds: dt[16] * dt[12],
          fc_assembly_seconds: dt[16] * dt[13],
          fc_cash_seconds: dt[16] * dt[14],
          fc_svs_seconds: dt[16] * dt[15],
          matcher: store.id.to_s + '-' + dt[2]
          )
      end
    end
  end

  def convert_time(date_string, time_string)
    # Parse date components: "2026-02-18"
    year, month, day = date_string.split('-').map(&:to_i)
    # Parse time components: "04:30:00" or "25:30:00" (hours can be >= 24)
    hour, minute, second = time_string.split(':').map(&:to_i)
    
    # Handle times beyond 24:00:00 (e.g., 25:30:00 = 1:30 AM next day)
    if hour >= 24
      adjusted_hour = hour % 24
      # Create DateTime with the base date, then add the extra days
      DateTime.new(year, month, day, adjusted_hour, minute, second)
    else
      # Create DateTime without timezone conversion
      DateTime.new(year, month, day, hour, minute, second)
    end
  end
end