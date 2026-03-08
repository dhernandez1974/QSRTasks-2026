class Datapass::CashDepositJob < ApplicationJob
	queue_as :default

	def perform(data, nsn, timestamp)
		store = Store.find_by(number: nsn.to_i)
		data["data"].each do |dep|
			deposit = CashDeposit.find_by(nsn: store.number, store_busn_dt: dep[1], bank_dposit_cd: dep[3])
			if deposit
				deposit.update(
					dpos_entr_tim: dep[2],
					vfy_dpos_date: dep[4],
					system_date: dep[5],
					dcr_dpos_crlos_amt: dep[6],
					dcr_dpos_pcash_amt: dep[7],
					count_bnk_dpos_amt: dep[8],
					vfy_dpos_amt: dep[9],
					dpos_user_eid: dep[10],
					dpos_emp_eid: dep[11],
					vfy_dpos_eid: dep[12],
					dposit_bag_id_num: dep[13],
					fcurr_curr_cd: dep[14],
					day_fcurr_dpos_amt: dep[15],
					day_usd_dpos_amt: dep[16]
				)
			else
				CashDeposit.create(
					nsn: store.number,
					store_busn_dt: dep[1],
					dpos_entr_tim: dep[2],
					bank_dposit_cd: dep[3],
					vfy_dpos_date: dep[4],
					system_date: dep[5],
					dcr_dpos_crlos_amt: dep[6],
					dcr_dpos_pcash_amt: dep[7],
					count_bnk_dpos_amt: dep[8],
					vfy_dpos_amt: dep[9],
					dpos_user_eid: dep[10],
					dpos_emp_eid: dep[11],
					vfy_dpos_eid: dep[12],
					dposit_bag_id_num: dep[13],
					fcurr_curr_cd: dep[14],
					day_fcurr_dpos_amt: dep[15],
					day_usd_dpos_amt: dep[16]
				)
			end
		end
	end
end
