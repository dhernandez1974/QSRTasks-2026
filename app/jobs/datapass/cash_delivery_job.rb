class Datapass::CashDeliveryJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Store.find_by(number: nsn.to_i)
    data["data"].each do |del|
      delivery = CashDelivery.find_by(store_id: store.id, store_busn_date: del[1], provider_name: del[2] )
      if delivery
        delivery.update(store_id: store.id, store_busn_date: del[1], provider_name: del[2], sales_qty: del[3],
          net_sales_amt: del[4], gross_sales_amt: del[5], tax_total: del[6], tax_1: del[7], tax_2: del[8], tax_3: del[9],
          tax_4: del[10], integrated_delivery_fee_amt: del[11], integrated_delivery_fee_qty: del[12],
          integrated_service_fee_amt: del[13], integrated_service_fee_qty: del[14], integrated_small_order_fee_amt: del[15],
          integrated_small_order_fee_qty: del[16], integrated_tip_amt: del[17], integrated_tip_qty: del[18],
          channel_origin: del[19])
      else
        CashDelivery.create(store_id: store.id, store_busn_date: del[1], provider_name: del[2], sales_qty: del[3],
          net_sales_amt: del[4], gross_sales_amt: del[5], tax_total: del[6], tax_1: del[7], tax_2: del[8], tax_3: del[9],
          tax_4: del[10], integrated_delivery_fee_amt: del[11], integrated_delivery_fee_qty: del[12],
          integrated_service_fee_amt: del[13], integrated_service_fee_qty: del[14], integrated_small_order_fee_amt: del[15],
          integrated_small_order_fee_qty: del[16], integrated_tip_amt: del[17], integrated_tip_qty: del[18],
          channel_origin: del[19])
      end
    end
  end
end
