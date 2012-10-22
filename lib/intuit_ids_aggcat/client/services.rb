require 'oauth'
require 'rexml/document'
require 'xml/mapping'
require 'intuit_ids_aggcat/client/intuit_xml_mappings'

module IntuitIdsAggcat

  module Client
    
    class Services

      class << self

        def initialize
          IntuitIdsAggcat::Client::Saml.get_tokens
        end

        def get_institutions oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens, consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret
          response_xml = oauth_get_request "https://financialdatafeed.platform.intuit.com/rest-war/v1/institutions", oauth_token_info, consumer_key, consumer_secret
          institutions = Institutions.load_from_xml(response_xml.root)
          institutions.institutions
        end

        def get_institution_detail id, oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens, consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret
          response_xml = oauth_get_request "https://financialdatafeed.platform.intuit.com/rest-war/v1/institutions/#{id}", oauth_token_info, consumer_key, consumer_secret
          institutions = InstitutionDetail.load_from_xml(response_xml.root)
          institutions
        end

        #def discover_and_add_accounts institution_id, options, oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens, consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret
        #  url = "https://financialdatafeed.platform.intuit.com/rest-war/v1/institutions/#{institution_id}/logins"
        #  oauth_token = oauth_token_info[:oauth_token]
        #  oauth_token_secret = oauth_token_info[:oauth_token_secret]

        #   options = { :request_token_path => 'https://financialdatafeed.platform.intuit.com',
        #               :timeout => timeout}
        #   consumer = OAuth::Consumer.new(consumer_key, consumer_secret, options)
        #   access_token = OAuth::AccessToken.new(consumer, oauth_token, oauth_token_secret)
        #   xml = 
        #   response = access_token.post(url, { "Content-Type"=>'application/xml', 'Host' => 'financialdatafeed.platform.intuit.com' })
        #   response_xml = REXML::Document.new response.body
        # end

        def oauth_get_request url, oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens, consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret, timeout = 120
          oauth_token = oauth_token_info[:oauth_token]
          oauth_token_secret = oauth_token_info[:oauth_token_secret]

          options = { :request_token_path => 'https://financialdatafeed.platform.intuit.com', :timeout => timeout} 
          consumer = OAuth::Consumer.new(consumer_key, consumer_secret, options)
          access_token = OAuth::AccessToken.new(consumer, oauth_token, oauth_token_secret)
          response = access_token.get(url, { "Content-Type"=>'application/xml', 'Host' => 'financialdatafeed.platform.intuit.com' })
          response_xml = REXML::Document.new response.body
        end
    
      end
    end
  end
end
