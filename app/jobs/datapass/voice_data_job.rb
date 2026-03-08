require 'csv'

class Datapass::VoiceDataJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Organization::Location.find_by(number: nsn.to_i)
    return unless store

    CSV.parse(data, headers: true) do |row|
      voice_data = VoiceData.find_or_initialize_by(
        level_val: row['LEVEL_VAL'],
        cust_visit_dt: row['CUST_REST_VIS_DT'],
        pos_area_ds: row['POS_AREA_DS']
      )

      voice_data.assign_attributes(
        level_na: row['LEVEL_NA'],
        csat_score_ovrl: row['CSAT_SCORE_OVERALL'],
        csat_score_frnd: row['CSAT_SCORE_FRIENDLY'],
        csat_score_fast: row['CSAT_SCORE_FAST'],
        csat_score_qlty: row['CSAT_SCORE_QUALITY'],
        csat_score_clen: row['CSAT_SCORE_CLEANLINESS'],
        csat_score_accu: row['CSAT_SCORE_ACCURACY'],
        ovrl_ansr_cnt_qt: row['OVRL_ANSR_CNT_QT'],
        ovrl_high_stsf_cnt_qt: row['OVRL_HIGH_STSF_CNT_QT'],
        frnd_ansr_cnt_qt: row['FRND_ANSR_CNT_QT'],
        frnd_high_stsf_cnt_qt: row['FRND_HIGH_STSF_CNT_QT'],
        fast_ansr_cnt_qt: row['FAST_ANSR_CNT_QT'],
        fast_high_stsf_cnt_qt: row['FAST_HIGH_STSF_CNT_QT'],
        qlty_ansr_cnt_qt: row['QLTY_ANSR_CNT_QT'],
        qlty_high_stsf_cnt_qt: row['QLTY_HIGH_STSF_CNT_QT'],
        clen_ansr_cnt_qt: row['CLEN_ANSR_CNT_QT'],
        clen_high_stsf_cnt_qt: row['CLEN_HIGH_STSF_CNT_QT'],
        accu_ansr_cnt_qt: row['ACCU_ANSR_CNT_QT'],
        accu_high_stsf_snt_qt: row['ACCU_HIGH_STSF_CNT_QT'],
        store_id: store.id,
        organization_id: store.organization_id
      )
      voice_data.save!
    end
  end
end
