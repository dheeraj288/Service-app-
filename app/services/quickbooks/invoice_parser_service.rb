# app/services/quickbooks/invoice_parser_service.rb
module Quickbooks
  class InvoiceParserService
    def self.customer_view(invoice_data)
      invoice = invoice_data['Invoice']
      {
        invoice_id: invoice['Id'],
        invoice_number: invoice['DocNumber'],
        date: invoice['TxnDate'],
        due_date: invoice['DueDate'],
        total_amount: invoice['TotalAmt'],
        balance_due: invoice['Balance'],
        currency: invoice.dig('CurrencyRef', 'name'),
        customer_name: invoice.dig('CustomerRef', 'name'),
        billing_address: format_address(invoice['BillAddr']),
        items: format_line_items(invoice['Line'])
      }
    end

    def self.format_address(address)
      return unless address
      [
        address['Line1'],
        address['Line2'],
        address['City'],
        address['CountrySubDivisionCode'],
        address['PostalCode']
      ].compact.join(', ')
    end

    def self.format_line_items(lines)
      lines.select { |line| line['DetailType'] == 'SalesItemLineDetail' }.map do |line|
        {
          name: line.dig('SalesItemLineDetail', 'ItemRef', 'name'),
          quantity: line.dig('SalesItemLineDetail', 'Qty') || 1,
          amount: line['Amount']
        }
      end
    end
  end
end
