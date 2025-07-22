module Api
  module V1
    class QuickbooksAuthController < ApplicationController
      skip_before_action :authorize_request, only: [:callback]
      before_action :authorize_request, except: [:callback]
      before_action :set_current_shop, only: [:callback, :create_invoice]

      def connect
        auth_url = Quickbooks::AuthService.new.authorization_url
        render json: { auth_url: }
      end

      def callback
        service = Quickbooks::AuthService.new(@current_shop)
        tokens = service.store_token(params[:code], params[:realmId])
        render json: {
          message: 'QuickBooks credentials updated successfully',
          access_token: tokens[:access_token],
          refresh_token: tokens[:refresh_token],
          realm_id: tokens[:realm_id]
        }
      end

      def create_invoice
        service = Quickbooks::AuthService.new(@current_shop)
        begin
          result = service.create_invoice(params)

          if result['code'] == 200
            invoice = result['Invoice']

            render json: {
              message: "Invoice created successfully",
              invoice_id: invoice["Id"],
              doc_number: invoice["DocNumber"],
              date: invoice["TxnDate"],
              due_date: invoice["DueDate"],
              customer: invoice.dig("CustomerRef", "name"),
              total_amount: invoice["TotalAmt"],
              balance: invoice["Balance"],
              line_items: invoice["Line"].select { |l| l["DetailType"] == "SalesItemLineDetail" }.map do |line|
                {
                  description: line["Description"],
                  amount: line["Amount"],
                  item_name: line.dig("SalesItemLineDetail", "ItemRef", "name"),
                  quantity: line.dig("SalesItemLineDetail", "Qty")
                }
              end
            }
          else
            render json: { error: "Failed to create invoice", details: result }, status: :unprocessable_entity
          end
        rescue => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end

      private

      def set_current_shop
        @current_shop = User.first&.shop
        render json: { error: 'No shop found for the user' }, status: :unprocessable_entity unless @current_shop
      end
    end
  end
end
