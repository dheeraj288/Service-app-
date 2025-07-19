require 'prawn'
require 'prawn/table'

class GenerateInvoicePdf
  def initialize(time_ticket)
  	debugger
    @time_ticket = time_ticket
    @service_request = time_ticket.service_request
    @technician = time_ticket.technician
    @shop = @technician.shop
  end

  def call
    pdf_path = generate_pdf
    { pdf_url: pdf_path }
  end

  private

  def generate_pdf
    file_name = "invoice_#{@time_ticket.id}.pdf"
    folder_path = Rails.root.join("public", "invoices")
    FileUtils.mkdir_p(folder_path) unless Dir.exist?(folder_path)

    full_path = folder_path.join(file_name)

    Prawn::Document.generate(full_path, page_size: 'A4', margin: 40) do |pdf|
      # ====== HEADER ======
      pdf.text @shop&.name || "TechService Inc.", size: 22, style: :bold
      pdf.move_down 5
      pdf.text @shop&.try(:address) || "1234 Main Street, City, State"
      pdf.text "Phone: #{@shop&.try(:phone) || '123-456-7890'}"
      pdf.text "Email: #{@shop&.try(:email) || 'support@techservice.com'}"
      pdf.move_down 20

      # ====== INVOICE TITLE ======
      pdf.text "INVOICE", size: 18, style: :bold, align: :center
      pdf.move_down 10

      # ====== BASIC DETAILS ======
      pdf.text "Invoice #: #{@time_ticket.id}", size: 12
      pdf.text "Date: #{@time_ticket.start_time.strftime('%d-%m-%Y')}", size: 12
      pdf.text "Technician: #{@technician.name}", size: 12
      pdf.text "Service Request ID: #{@service_request.id}", size: 12
      pdf.move_down 20

      # ====== DUMMY LINE ITEMS ======
      data = [
        ["Description", "Hours", "Rate", "Amount"],
        ["Inspection", "1.0", "$50", "$50"],
        ["Repair Work", "2.0", "$70", "$140"],
        ["Final Testing", "0.5", "$60", "$30"]
      ]

      pdf.table(data, header: true, row_colors: ["F0F0F0", "FFFFFF"], width: pdf.bounds.width) do
        row(0).font_style = :bold
        columns(1..3).align = :right
      end

      pdf.move_down 15

      # ====== TOTALS ======
      total_hours = @time_ticket.total_hours || 3.5
      total_amount = "$220" # Change with your own calculation if needed
      pdf.text "Total Hours: #{total_hours}", size: 12
      pdf.text "Total Amount: #{total_amount}", size: 14, style: :bold

      # ====== FOOTER ======
      pdf.move_down 30
      pdf.stroke_horizontal_rule
      pdf.move_down 10
      pdf.text "Thank you for choosing #{@shop&.name || 'TechService Inc.'}.", align: :center, size: 10
      pdf.text "Contact: #{@shop&.try(:email) || 'support@techservice.com'}", align: :center, size: 10
    end

    "invoices/#{file_name}"
  end
end
