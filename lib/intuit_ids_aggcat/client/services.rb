require 'oauth'
require 'xml/mapping'
module IntuitIdsAggcat

  module Client
    
    # forward classdefs for mapping
    class Institution; end

    class Institutions
      include XML::Mapping
      array_node :institutions, "institution", :class=>Institution, :default_value => []
    end

    class Institution
      include XML::Mapping
      text_node :id, "institutionId", :default_value => nil
      text_node :name, "institutionName", :default_value => nil
    end

    class Services

      class << self

        def initialize
          IntuitIdsAggcat::Client::Saml.get_tokens
        end

        def get_institutions(oauth_token_info = IntuitIdsAggcat::Client::Saml.get_tokens, consumer_key = IntuitIdsAggcat.config.oauth_consumer_key, consumer_secret = IntuitIdsAggcat.config.oauth_consumer_secret)
          # Specify AggCat API endpoint
  
          oauth_token = oauth_token_info[:oauth_token]
          oauth_token_secret = oauth_token_info[:oauth_token_secret]

          options = { :request_token_path => 'https://financialdatafeed.platform.intuit.com',
                      :timeout => 120}
          # Use your API key and secret to instantiate consumer object
          consumer = OAuth::Consumer.new(consumer_key, consumer_secret, options)
          
          # # Use your developer token and secret to instantiate access token object
          access_token = OAuth::AccessToken.new(consumer, oauth_token, oauth_token_secret)
         
          # Call AggCat service:
         
          response = access_token.get("https://financialdatafeed.platform.intuit.com/rest-war/v1/institutions", 
                 { "Content-Type"=>'application/xml', 'Host' => 'financialdatafeed.platform.intuit.com' })
          #puts "response: #{response.code}"
          institutions = Institutions.load_from_xml(response.body)
          #File.open("institutions.xml", 'w') do |f|
          #  f.write(response.body)
          #end

        end

    
      end
    end
  end
end
