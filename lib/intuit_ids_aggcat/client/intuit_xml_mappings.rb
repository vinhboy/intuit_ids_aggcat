# forward classdefs for mapping
module IntuitIdsAggcat
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
  class Choice; end

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
      # for challengeResponses/response
      xml.each_element("//response") do |x| 
        x.add_namespace "v11", "http://schema.intuit.com/platform/fdatafeed/challenge/v1"
        x.name = "v11:response"
      end
      # for challengeResponses root
      xml.each_element("//challengeResponses") do |x| 
        x.add_namespace "v1", "http://schema.intuit.com/platform/fdatafeed/institutionlogin/v1"
        x.name = "challengeResponses"
      end
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
    object_node :challenge, "challenge", :class => Challenge, :default_value => nil
  end

  class Choice
    include XML::Mapping
    text_node :text, "text", :default_value => nil
    text_node :val, "val", :default_value => nil
  end

  class Challenge
    include XML::Mapping
    text_node :text, "text", :default_value => nil
    text_node :image, "image", :default_value => nil
    array_node :choice, "choice", :class => Choice, :default_value => nil
  end

  class ChallengeResponses
    include XML::Mapping
    def post_save xml, options={:mapping=>:_default}
      # using REXML's element na1espace method doesn't seem to set the namespace correctly...?
      xml.root.add_namespace "v1", "http://schema.intuit.com/platform/fdatafeed/institutionlogin/v1"
      xml.each_element("//response"){|x| x.add_namespace "v11", "http://schema.intuit.com/platform/fdatafeed/challenge/v1"}
      xml
    end
    self.root_element_name "ChallengeResponses"
    array_node :response, "response", :class => String
  end

  class AccountList
    include XML::Mapping
    array_node :banking_accounts, "BankingAccount", :class => BankingAccount, :default_value => nil
    array_node :credit_accounts, "CreditAccount", :class => CreditAccount, :default_value => nil
    #array_node :loan_accounts, "LoanAccount", :default_value => nil
    #array_node :investment_accounts, "InvestmentAccount", :default_value => nil
    #array_node :rewards_accounts, "RewardsAccount", :default_value => nil
    #array_node :other_accounts, "OtherAccount", :default_value => nil
  end

  class Account
    include XML::Mapping
    numeric_node :account_id, "accountId", :default_value => nil
    text_node :status, "status", :default_value => nil
    text_node :account_number, "accountNumber", :default_value => nil
    text_node :account_number_real, "accountNumberReal", :default_value => nil
    text_node :account_nickname, "accountNickname", :default_value => nil
    numeric_node :display_position, "displayPosition", :default_value => nil
    numeric_node :institution_id, "institutionId", :default_value => nil
    text_node :description, "description", :default_value => nil
    text_node :registered_user_name, "registeredUserName", :default_value => nil
    numeric_node :balance_amount, "balanceAmount", :default_value => nil
    text_node :balance_date, "balanceDate", :default_value => nil
    numeric_node :balance_previous_amount, "balancePreviousAmount", :default_value => nil
    text_node :last_transaction_date, "lastTxnDate", :default_value => nil
    text_node :aggregation_success_date, "aggrSuccessDate", :default_value => nil
    text_node :aggregation_attempt_date, "aggrAttemptDate", :default_value => nil
    text_node :currency_code, "currencyCode", :default_value => nil
    text_node :bank_id, "bankId", :default_value => nil
    numeric_node :institution_login_id, "institutionLongId", :default_value => nil
  end

  class BankingAccount < Account
    include XML::Mapping
    text_node :banking_account_type, "bankingAccountType", :default_value => nil
    text_node :posted_date, "postedDate", :default_value => nil
    numeric_node :available_balance_amount, "availableBalanceAmount", :default_value => nil
    text_node :origination_date, "originationDate", :default_value => nil
    text_node :open_date, "openDate", :default_value => nil
    numeric_node :period_interest_rate, "periodInterestRate", :default_value => nil
    numeric_node :period_deposit_amount, "periodDepositAmount", :default_value => nil
    numeric_node :period_interest_amount, "periodInterestAmount", :default_value => nil
    numeric_node :interest_amount_ytd, "interestAmountYtd", :default_value => nil
    numeric_node :interest_prior_amount_ytd, "interestPriorAmountYtd", :default_value => nil
    text_node :maturity_date, "maturityDate", :default_value => nil
    numeric_node :maturity_amount, "maturityAmount", :default_value => nil
  end

  class CreditAccount < Account
    include XML::Mapping
    text_node :credit_account_type, "creditAccountType", :default_value => nil
    text_node :detailed_description, "detailedDescription", :default_value => nil
    numeric_node :interest_rate, "interestRate", :default_value => nil
    numeric_node :credit_available_amount, "creditAvailableAmount", :default_value => nil
    numeric_node :credit_max_amount, "creditMaxAmount", :default_value => nil
    numeric_node :cash_advance_max_amount, "cashAdvanceMaxAmount", :default_value => nil
    numeric_node :cash_advance_balance, "cashAdvanceBalance", :default_value => nil
    numeric_node :cash_advance_interest_rate, "cashAdvanceInterestRate", :default_value => nil
    numeric_node :current_balance, "currentBalance", :default_value => nil
    numeric_node :payment_min_amount, "paymentMinAmount", :default_value => nil
    text_node :payment_due_date, "paymentDueDate", :default_value => nil
    numeric_node :previous_balance, "previousBalance", :default_value => nil
    text_node :statement_end_date, "statementEndDate", :default_value => nil
    numeric_node :statement_purchase_amount, "statementPurchaseAmount", :default_value => nil
    numeric_node :statement_finance_amount, "statementFinanceAmount", :default_value => nil
    numeric_node :past_due_amount, "pastDueAmount", :default_value => nil
    numeric_node :last_payment_amount, "lastPaymentAmount", :default_value => nil
    text_node :last_payment_date, "lastPaymentDate", :default_value => nil
    numeric_node :statement_close_balance, "statementCloseBalance", :default_value => nil
    numeric_node :statement_last_fee_amount, "statementLastFeeAmount", :default_value => nil
  end
end