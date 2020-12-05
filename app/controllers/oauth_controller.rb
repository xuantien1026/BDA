require 'google/apis/analytics_v3'
require 'google/api_client/client_secrets'
require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'googleauth/stores/file_token_store'

class OauthController < ApplicationController
  def index
    # authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
    #   json_key_io: File.open(Rails.root.join('client_secrets.json')),
    #   scope: Google::Apis::AnalyticsV3::AUTH_ANALYTICS_READONLY,
    # )
    #
    # @access_token = authorizer.fetch_access_token!
    # File.open('./credential.json', 'w') do |f|
    #   f.write(@access_token)
    # end

    # client.authorization = authorizer
    # @ga_data = client.get_ga_data('ga:124563799', '30daysAgo', 'yesterday', 'ga:pageviews')
    #
    client_id = Google::Auth::ClientId.from_file(Rails.root.join('client_secrets.json'))
    scope = [Google::Apis::AnalyticsV3::AUTH_ANALYTICS_READONLY]
    token_store = Google::Auth::Stores::FileTokenStore.new(file: Rails.root.join('credentials.yaml'))
    authorizer = Google::Auth::WebUserAuthorizer.new(client_id, scope, token_store, '/callback')

    user_id = 1
    @credential = authorizer.get_credentials(user_id, request)
    if @credential.nil?
      redirect_to authorizer.get_authorization_url(login_hint: user_id, request: request)
    end

    client = Google::Apis::AnalyticsV3::AnalyticsService.new
    client.authorization = @credential
    @ga_data = client.get_ga_data('ga:124563799', '30daysAgo', 'yesterday', 'ga:pageviews', dimensions: 'ga:pageTitle', max_results: 10)
    @label = @ga_data.rows.map { |r| r[0][0..15] }.to_json
    @data = @ga_data.rows.map { |r| r[1] }.to_json
  end
end