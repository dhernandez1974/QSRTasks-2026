class CashHourlySaleJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Store.find_by(number: nsn.to_i)
    data["data"].each do |hr|
      h, m = hr[2].split(":").map(&:to_i)
      st = (Time.zone.parse("00:00") + h.hours + m.minutes).strftime("%H:%M")
      hourly = CashHourlySale.find_by(store_id: store.id, store_busn_date: hr[1], start_time: st)
      if hourly
        hourly.update(prod_sales: hr[3], trans_count: hr[4], dt_prod_sales: hr[5], dt_trans_count: hr[6])
      else
        CashHourlySale.create(store_id: store.id, store_busn_date: hr[1], start_time: st, prod_sales:
          hr[3], trans_count: hr[4], dt_prod_sales: hr[5], dt_trans_count: hr[6])
      end
    end
  end
end