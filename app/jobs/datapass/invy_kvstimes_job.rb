class InvyKvstimesJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Store.find_by(number: nsn.to_i)
    data["data"].each do |kvs|
      InvyKvstime.find_or_create_by(matcher: store.id.to_s + '-' + kvs[1] + '-' + kvs[2].to_s + '-' + kvs[3]) do |rec|
        rec.update(
          store_id: store.id,
          store_busn_dt: kvs[1],
          qtr_hr_end_time: convert_time(kvs[1], kvs[2]),
          kvs_typ: kvs[3],
          qtr_hr_order_tim: kvs[4],
          qtr_hr_prod_time: kvs[5],
          qtr_hr_ttl_tim: kvs[6],
          qtr_kvs_trns_qty: kvs[7],
          qtr_kvs_sand_qty: kvs[8],
          order_avg_time: if kvs[7] > 0
                            !kvs[4].nil? ? kvs[4] / kvs[7] : 0
                          else 0
                          end,
          prod_avg_time: kvs[7] > 0 ? kvs[5] / kvs[7] : 0,
          ttl_avg_time: kvs[7] > 0 ? kvs[6] / kvs[7] : 0,
          matcher: store.id.to_s + '-' + kvs[2].to_s + '-' + kvs[3]
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