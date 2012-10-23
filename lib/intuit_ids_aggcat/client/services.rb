require 'oauth'
require 'rexml/document'
require 'xml/mapping'
require 'intuit_ids_aggcat/client/intuit_xml_mappings'

module IntuitIdsAggcat

  module Client
    
    class Services

      class << self

        def initialize
          
        end

        ##
        # Gets all institutions supported by Intuit. If oauth_token_info isn't provided, new tokens are provisioned using "default" user
        # consumer_key and consumer_secret will be retrieved from the Configuration class if not provided
        def get_institutions oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens("default"), consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret
          response = oauth_get_request "https://financialdatafeed.platform.intuit.com/rest-war/v1/institutions", oauth_token_info, consumer_key, consumer_secret
          institutions = Institutions.load_from_xml(response[:response_xml].root)
          File.open("institutions.xml", 'w') {|f| f.write(response[:response_xml].to_s) }
          institutions.institutions
        end

        ##
        # Gets the institution details for id. If oauth_token_info isn't provided, new tokens are provisioned using "default" user
        # consumer_key and consumer_secret will be retrieved from the Configuration class if not provided
        def get_institution_detail id, oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens("default"), consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret
          response = oauth_get_request "https://financialdatafeed.platform.intuit.com/rest-war/v1/institutions/#{id}", oauth_token_info, consumer_key, consumer_secret
          institutions = InstitutionDetail.load_from_xml(response[:response_xml].root)
          institutions
        end

        ##
        # Deletes the customer's accounts from aggregation at Intuit.
        # username must be provided, if no oauth_token_info is provided, new tokens will be provisioned using username
        def delete_customer username, oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens(username), consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret
          url = "https://financialdatafeed.platform.intuit.com/rest-war/v1/customers/"
          oauth_delete_request url, oauth_token_info
        end

        ##
        # Discovers and adds accounts using credentials
        # institution_id is the ID of the institution, username is the ID for this customer's accounts at Intuit and must be used for future requests,
        # creds_hash is a hash object of key value pairs used for authentication
        # If oauth_token is not provided, new tokens will be provisioned using the username provided
        # TODO: This currently does not support MFA/challenge response
        def discover_and_add_accounts_with_credentials institution_id, username, creds_hash, oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens(username), consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret, timeout = 30
          url = "https://financialdatafeed.platform.intuit.com/rest-war/v1/institutions/#{institution_id}/logins"
          credentials_array = []
          creds_hash.each do |k,v|
            c = Credential.new
            c.name = k
            c.value = v
            credentials_array.push c
          end
          creds = Credentials.new
          creds.credential = credentials_array
          il = InstitutionLogin.new
          il.credentials = creds
          oauth_post_request url, il.save_to_xml.to_s, oauth_token_info
        end

        ##
        # Helper method to issue post requests
        def oauth_post_request url, body, oauth_token_info, consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret, timeout = 120
          oauth_token = oauth_token_info[:oauth_token]
          oauth_token_secret = oauth_token_info[:oauth_token_secret]

          options = { :request_token_path => 'https://financialdatafeed.platform.intuit.com', :timeout => timeout} 
          consumer = OAuth::Consumer.new(consumer_key, consumer_secret, options)
          access_token = OAuth::AccessToken.new(consumer, oauth_token, oauth_token_secret)
          response = access_token.post(url, body, { "Content-Type"=>'application/xml', 'Host' => 'financialdatafeed.platform.intuit.com' })
          response_xml = REXML::Document.new response.body
          { :response_code => response.code, :response_xml => response_xml }
        end
        ##
        # Helper method to issue get requests
        def oauth_get_request url, oauth_token_info, consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret, timeout = 120
          oauth_token = oauth_token_info[:oauth_token]
          oauth_token_secret = oauth_token_info[:oauth_token_secret]

          options = { :request_token_path => 'https://financialdatafeed.platform.intuit.com', :timeout => timeout} 
          consumer = OAuth::Consumer.new(consumer_key, consumer_secret, options)
          access_token = OAuth::AccessToken.new(consumer, oauth_token, oauth_token_secret)
          response = access_token.get(url, { "Content-Type"=>'application/xml', 'Host' => 'financialdatafeed.platform.intuit.com' })
          response_xml = REXML::Document.new response.body
          { :response_code => response.code, :response_xml => response_xml }
        end

        ##
        # Helper method to issue delete requests
        def oauth_delete_request url, oauth_token_info, consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret, timeout = 120
          oauth_token = oauth_token_info[:oauth_token]
          oauth_token_secret = oauth_token_info[:oauth_token_secret]

          options = { :request_token_path => 'https://financialdatafeed.platform.intuit.com', :timeout => timeout} 
          consumer = OAuth::Consumer.new(consumer_key, consumer_secret, options)
          access_token = OAuth::AccessToken.new(consumer, oauth_token, oauth_token_secret)
          response = access_token.delete(url, { "Content-Type"=>'application/xml', 'Host' => 'financialdatafeed.platform.intuit.com' })
          response_xml = REXML::Document.new response.body
          { :response_code => response.code, :response_xml => response_xml }
        end
    
      end
    end
  end
end
