require 'csv'

class InvoiceJob < ApplicationJob
  queue_as :default

  def perform(data, nsn, timestamp)
    store = Store.find_by(number: nsn.to_i)
    return unless store

    invoice = nil
    CSV.parse(data, headers: false).each do |row|
      line_type = row[9].to_i

      if line_type == 1
        invoice = Invoice.find_or_initialize_by(
          invoice_number: row[4],
          store_id: store.id
        )
        invoice.invoice_line_items.destroy_all unless invoice.new_record?
        invoice.update!(
          organization_id: store.organization_id,
          dc: row[0],
          dc_name: row[1],
          eid: row[2],
          store_number: row[3],
          invoice_date: row[6],
          delivery_date: row[7],
          term_date: row[8]
        )
      elsif [2, 3, 4, 5].include?(line_type)
        InvoiceLineItem.create!(
          invoice: invoice,
          organization_id: store.organization_id,
          store_id: store.id,
          dc: row[0],
          dc_name: row[1],
          eid: row[2],
          store_number: row[3],
          invoice_number: row[4],
          line_type: row[9],
          account_id: row[10],
          wrin: row[11],
          invoice_quantity: row[12],
          case_price: row[13],
          item_description: row[14],
          inner_pack_description: row[15],
          extended_price: row[16],
          total_tax: row[17]
        )

        if line_type == 4
          invoice.update!(
            invoice_quantity: row[12],
            invoice_subtotal: row[16],
            total_tax: row[17],
            invoice_total: row[18]
          )
        end
      end
    end
  end

end
