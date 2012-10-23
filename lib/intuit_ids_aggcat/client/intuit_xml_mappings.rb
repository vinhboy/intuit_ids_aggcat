# forward classdefs for mapping
class Institution; end
class Address; end
class Key; end
class Credentials; end
class Credential; end
class Challenge; end
class ChallengeResponses; end

class Institutions
  include XML::Mapping
  array_node :institutions, "institution", :class=>Institution, :default_value => []
end

class Institution
  include XML::Mapping
  text_node :id, "institutionId", :default_value => nil
  text_node :name, "institutionName", :default_value => nil
  text_node :url, "homeUrl", :default_value => nil
  text_node :phone, "phoneNumber", :default_value => nil
  boolean_node :virtual, "virtual", "true", "false", :default_value => true
end

class InstitutionDetail
  include XML::Mapping
  text_node :id, "institutionId", :default_value => nil
  text_node :name, "institutionName", :default_value => nil
  text_node :url, "homeUrl", :default_value => nil
  text_node :phone, "phoneNumber", :default_value => nil
  boolean_node :virtual, "virtual", "true", "false", :default_value => true
  text_node :currency_code, "currencyCode", :default_value => nil
  text_node :email_address, "emailAddress", :default_value => nil
  text_node :special_text, "specialText", :default_value => nil
  object_node :address, "address", :default_value => nil
  array_node :keys, "keys/key", :class=>Key, :default_value => []
end

class Address
  include XML::Mapping
  text_node :address1, "address1", :default_value => nil
  text_node :address2, "address2", :default_value => nil
  text_node :address3, "address3", :default_value => nil
  text_node :city, "city", :default_value => nil
  text_node :state, "state", :default_value => nil
  text_node :postal_code, "postalCode", :default_value => nil
  text_node :country, "country", :default_value => nil
end

class Key
  include XML::Mapping
  text_node :name, "name", :default_value => nil
  text_node :status, "status", :default_value => nil
  text_node :min_length, "valueLengthMin", :default_value => nil
  text_node :max_length, "valueLengthMax", :default_value => nil
  boolean_node :is_displayed, "displayFlag", "true", "false", :default_value => true
  boolean_node :is_masked, "mask", "true", "false", :default_value => false
  text_node :display_order, "displayOrder", :default_value => nil
  text_node :instructions, "instructions", :default_value => nil
  text_node :description, "description", :default_value => nil
end

class InstitutionLogin
  include XML::Mapping
  # added namespaces to make root element compliant with Intuit's expectation
  def post_save xml, options={:mapping=>:_default}
    # using REXML's element namespace method doesn't seem to set the namespace correctly...?
    xml.root.add_attributes("xmlns"=>"http://schema.intuit.com/platform/fdatafeed/institutionlogin/v1")
    xml.root.add_namespace "xsi", "http://www.w3.org/2001/XMLSchema-instance"
    xml.root.add_namespace "xsd", "http://www.w3.org/2001/XMLSchema"
  end
  self.root_element_name "InstitutionLogin"
  object_node :credentials, "credentials", :default_value => nil
  object_node :challenge_responses, "challengeResponses", :default_value => nil
end

class Credentials
  include XML::Mapping
  array_node :credential, "credential", :default_value => nil
end

class Credential
  include XML::Mapping
  text_node :name, "name", :default_value => nil
  text_node :value, "value", :default_value => nil
end

class Challenges
  include XML::Mapping
  object_node :challenge, "challenge", :default_value => nil
end

class Challenge
  include XML::Mapping
  text_node :text, "text", :default_value => nil
  text_node :image, "image", :default_value => nil
end

class ChallengeResponses
  include XML::Mapping
  text_node :response, "response", :default_value => nil
end