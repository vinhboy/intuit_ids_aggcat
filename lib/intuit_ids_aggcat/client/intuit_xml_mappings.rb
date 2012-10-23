# forward classdefs for mapping
class Institution; end
class Address; end
class Key; end
class Credentials; end
class Credential; end
class Challenge; end
class ChallengeResponses; end
class Account; end
class BankingAccount < Account; end
class CreditAccount < Account; end
class LoanAccount < Account; end
class InvestmentAccount < Account; end
class RewardsAccount < Account; end
class OtherAccount < Account; end

class Institutions
  include XML::Mapping
  array_node :institutions, "institution", :class=>Institution, :default_value => []
end

class Institution
  include XML::Mapping
  numeric_node :id, "institutionId", :default_value => nil
  text_node :name, "institutionName", :default_value => nil
  text_node :url, "homeUrl", :default_value => nil
  text_node :phone, "phoneNumber", :default_value => nil
  boolean_node :virtual, "virtual", "true", "false", :default_value => true
end

class InstitutionDetail
  include XML::Mapping
  numeric_node :id, "institutionId", :default_value => nil
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

class AccountList
  include XML::Mapping
  array_node :banking_accounts, "BankingAccount"
  array_node :credit_accounts, "CreditAccount"
  array_node :loan_accounts, "LoanAccount"
  array_node :investment_accounts, "InvestmentAccount"
  array_node :rewards_accounts, "RewardsAccount"
  array_node :other_accounts, "OtherAccount"
end

class Account
  include XML::Mapping
  numeric_node :account_id, "accountId"
  text_node :status, "status"
  text_node :account_number, "accountNumber"
  text_node :account_number_real, "accountNumberReal"
  text_node :account_nickname, "accountNickname"
  numeric_node :display_position, "displayPosition"
  numeric_node :institution_id, "institutionId"
  text_node :description, "description"
  text_node :registered_user_name, "registeredUserName"
  numeric_node :balance_amount, "balanceAmount"
  text_node :balance_date, "balanceDate"
  numeric_node :balance_previous_amount, "balancePreviousAmount"
  text_node :last_transaction_date, "lastTxnDate"
  text_node :aggregation_success_date, "aggrSuccessDate"
  text_node :aggregation_attempt_date, "aggrAttemptDate"
  text_node :currency_code, "currencyCode"
  text_node :bank_id, "bankId"
  numeric_node :institution_login_id, "institutionLongId"
end

class BankingAccount < Account
  text_node :banking_account_type, "bankingAccountType"
  text_node :posted_date, "postedDate"
  numeric_node :available_balance_amount, "availableBalanceAmount"
  text_node :origination_date, "originationDate"
  text_node :open_date, "openDate"
  numeric_node :period_interest_rate, "periodInterestRate"
  numeric_node :period_deposit_amount, "periodDepositAmount"
  numeric_node :period_interest_amount, "periodInterestAmount"
  numeric_node :interest_amount_ytd, "interestAmountYtd"
  numeric_node :interest_prior_amount_ytd, "interestPriorAmountYtd"
  text_node :maturity_date, "maturityDate"
  numeric_node :maturity_amount, "maturityAmount"
end

#class CreditAccount < Account
#end