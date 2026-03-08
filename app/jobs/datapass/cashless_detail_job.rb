class Datapass::CashlessDetailJob < ApplicationJob
	queue_as :default

	def perform(data, nsn, timestamp)
		store = Store.find_by(number: nsn.to_i)
		data["data"].each do |cs|
			cashless = CashlessDetail.find_by(nsn: store.number , store_busn_dt: cs[1], card_name: cs[2], source: cs[11])
			if cashless
				cashless.update(
					gross_amt: cs[3],
					gross_qty: cs[4],
					declines_amt: cs[5],
					declines_qty: cs[6],
					refund_amt: cs[7],
					refund_qty: cs[8],
					net_amt: cs[9],
					net_qty: cs[10],
				)
			else
				CashlessDetail.create(
					nsn: store.number,
					store_busn_dt: cs[1],
					card_name: cs[2],
					gross_amt: cs[3],
					gross_qty: cs[4],
					declines_amt: cs[5],
					declines_qty: cs[6],
					refund_amt: cs[7],
					refund_qty: cs[8],
					net_amt: cs[9],
					net_qty: cs[10],
					source: cs[11]
				)
			end
		end
	end
end
