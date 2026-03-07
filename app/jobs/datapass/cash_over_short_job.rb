class CashOverShortJob < ApplicationJob
	queue_as :default

	def perform(data, nsn, timestamp)
		store = Store.find_by(number: nsn.to_i)
		data["data"].each do |cash|
			overshort = CashOverShort.find_by(nsn: store.number, store_busn_dt: cash[1])
			if overshort
				overshort.update(
					cash_os: cash[2],
					gc_redeeemed_os: cash[3],
					couponaos: cash[4],
					couponbos: cash[5],
					couponcos: cash[6],
					coupondos: cash[7],
					couponeos: cash[8],
					cash_prior_amount: cash[9],
					cash_waiting_amount: cash[10],
					rounding_sum: cash[11]
				)
			else
				CashOverShort.create(
					nsn: store.number,
					store_busn_dt: cash[1],
					cash_os: cash[2],
					gc_redeeemed_os: cash[3],
					couponaos: cash[4],
					couponbos: cash[5],
					couponcos: cash[6],
					coupondos: cash[7],
					couponeos: cash[8],
					cash_prior_amount: cash[9],
					cash_waiting_amount: cash[10],
					rounding_sum: cash[11]
				)
			end
		end
	end
end
