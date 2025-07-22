# app/services/quickbooks/auth_service.rb
require 'oauth2'
require 'json'
require 'net/http'

module Quickbooks
  class AuthService
    REDIRECT_URI = ENV['QB_REDIRECT_URI']
    CLIENT_ID = ENV['QB_CLIENT_ID']
    CLIENT_SECRET = ENV['QB_CLIENT_SECRET']

    def initialize(shop = nil)
      @shop = shop
      @client = OAuth2::Client.new(
        CLIENT_ID,
        CLIENT_SECRET,
        site: 'https://appcenter.intuit.com/connect/oauth2',
        authorize_url: 'https://appcenter.intuit.com/connect/oauth2',
        token_url: 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer'
      )
    end

    def authorization_url
      @client.auth_code.authorize_url(
        redirect_uri: REDIRECT_URI,
        response_type: 'code',
        scope: 'com.intuit.quickbooks.accounting openid profile email phone address',
        state: SecureRandom.hex(10)
      )
    end

    def get_token(code)
      @client.auth_code.get_token(code, redirect_uri: REDIRECT_URI)
    end

    def store_token(code, realm_id)
      token = get_token(code)

      quickbooks_token = QuickbooksToken.find_or_initialize_by(shop_id: @shop.id)
      quickbooks_token.update!(
        access_token: token.token,
        refresh_token: token.refresh_token,
        realm_id: realm_id,
        expires_at: Time.current + token.expires_in.seconds
      )

      {
        access_token: token.token,
        refresh_token: token.refresh_token
      }
    end

    def create_invoice(params)
      quickbooks_token = @shop.quickbooks_token
      raise 'QuickBooks token not found' unless quickbooks_token

      uri = URI("https://sandbox-quickbooks.api.intuit.com/v3/company/#{quickbooks_token.realm_id}/invoice?minorversion=65")

      request = Net::HTTP::Post.new(uri).tap do |req|
        req["Authorization"] = "Bearer #{quickbooks_token.access_token}"
        req["Accept"] = "application/json"
        req["Content-Type"] = "application/json"
        req.body = build_invoice_payload(params).to_json
      end

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
      JSON.parse(response.body).merge('code' => response.code.to_i)
    end

    private

    def build_invoice_payload(params)
      {
        "CustomerRef": { "value": params[:customer_id] },
        "Line": params[:line_items].map do |item|
          {
            "Amount": item[:amount],
            "DetailType": "SalesItemLineDetail",
            "Description": item[:description],
            "SalesItemLineDetail": {
              "ItemRef": { "value": item[:item_id] },
              "Qty": item[:quantity] || 1
            }
          }
        end
      }
    end
  end
end
