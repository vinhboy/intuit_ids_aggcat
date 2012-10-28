# forward classdefs for mapping
class DateTimeNode < XML::Mapping::SingleAttributeNode
  def initialize(*args)
    path,*args = super(*args)
    @path = XML::XXPath.new(path)
    args
  end

  def extract_attr_value(xml)
    # without millisecs
    r1 = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}-\d{2}:\d{2}/
    # with millisecs
    r2 = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}-\d{2}:\d{2}/
    dt_format = ""
    dt_string = default_when_xpath_err{ @path.first(xml).text }
    if dt_string =~ r1
      dt_format = "%Y-%m-%dT%H:%M:%S%z"
    elsif dt_string =~ r2
      dt_format = "%Y-%m-%dT%H:%M:%S.%L%z"
    end
    DateTime.strptime(dt_string, dt_format)
  end

  def set_attr_value(xml, value)
    @path.first(xml,:ensure_created=>true).text = value
  end
end

XML::Mapping.add_node_class DateTimeNode

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
  class Transaction; end
  class BankingTransaction < Transaction; end
  class CreditCardTransaction < Transaction; end
  class InvestmentBankingTransaction < Transaction; end
  class InvestmentTransaction < Transaction; end
  class LoanTransaction < Transaction; end
  class RewardsTransaction < Transaction; end
  class TransactionList; end
  #class Common; end
  class Context; end

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
    date_time_node :balance_date, "balanceDate", :default_value => nil
    numeric_node :balance_previous_amount, "balancePreviousAmount", :default_value => nil
    date_time_node :last_transaction_date, "lastTxnDate", :default_value => nil
    date_time_node :aggregation_success_date, "aggrSuccessDate", :default_value => nil
    date_time_node :aggregation_attempt_date, "aggrAttemptDate", :default_value => nil
    text_node :currency_code, "currencyCode", :default_value => nil
    text_node :bank_id, "bankId", :default_value => nil
    numeric_node :institution_login_id, "institutionLongId", :default_value => nil
  end

  class BankingAccount < Account
    include XML::Mapping
    text_node :banking_account_type, "bankingAccountType", :default_value => nil
    date_time_node :posted_date, "postedDate", :default_value => nil
    numeric_node :available_balance_amount, "availableBalanceAmount", :default_value => nil
    date_time_node :origination_date, "originationDate", :default_value => nil
    date_time_node :open_date, "openDate", :default_value => nil
    numeric_node :period_interest_rate, "periodInterestRate", :default_value => nil
    numeric_node :period_deposit_amount, "periodDepositAmount", :default_value => nil
    numeric_node :period_interest_amount, "periodInterestAmount", :default_value => nil
    numeric_node :interest_amount_ytd, "interestAmountYtd", :default_value => nil
    numeric_node :interest_prior_amount_ytd, "interestPriorAmountYtd", :default_value => nil
    date_time_node :maturity_date, "maturityDate", :default_value => nil
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
    date_time_node :payment_due_date, "paymentDueDate", :default_value => nil
    numeric_node :previous_balance, "previousBalance", :default_value => nil
    date_time_node :statement_end_date, "statementEndDate", :default_value => nil
    numeric_node :statement_purchase_amount, "statementPurchaseAmount", :default_value => nil
    numeric_node :statement_finance_amount, "statementFinanceAmount", :default_value => nil
    numeric_node :past_due_amount, "pastDueAmount", :default_value => nil
    numeric_node :last_payment_amount, "lastPaymentAmount", :default_value => nil
    date_time_node :last_payment_date, "lastPaymentDate", :default_value => nil
    numeric_node :statement_close_balance, "statementCloseBalance", :default_value => nil
    numeric_node :statement_last_fee_amount, "statementLastFeeAmount", :default_value => nil
  end

  class Common
    include XML::Mapping
    text_node :normalized_payee_name, "normalizedPayeeName", :default_value => nil
  end

  class Context
    include XML::Mapping
    text_node :source, "source", :default_value => nil
    text_node :category_name, "categoryName", :default_value => nil
  end

  class Categorization
    include XML::Mapping
    object_node :common, "common", :class => Common, :default_value => nil
    object_node :context, "context", :class => Context, :default_value => nil
  end

  class Transaction
    include XML::Mapping
    numeric_node :id, "id", :default_value => nil
    text_node :currency_type, "currencyType", :default_value => nil
    text_node :institution_transaction_id, "institutionTransactionId", :default_value => nil
    text_node :correct_institution_transaction_id, "correctInstitutionTransactionId", :default_value => nil
    text_node :correct_action, "correctAction", :default_value => nil
    text_node :server_transaction_id, "serverTransactionId", :default_value => nil
    text_node :check_number, "checkNumber", :default_value => nil
    text_node :ref_number, "refNumber", :default_value => nil
    text_node :confirmation_number, "confirmationNumber", :default_value => nil
    text_node :payee_id, "payeeId", :default_value => nil
    text_node :payee_name, "payeeName", :default_value => nil
    text_node :normalized_payee_name, "normalizedPayeeName", :default_value => nil
    text_node :memo, "memo", :default_value => nil
    text_node :category, "category", :default_value => nil
    text_node :type, "type", :default_value => nil
    text_node :value_type, "valueType", :default_value => nil
    text_node :category_name, "categoryName", :default_value => nil
    text_node :ofx_category_name, "ofxCategoryName", :default_value => nil
    numeric_node :currency_rate, "currencyRate", :default_value => nil
    boolean_node :original_currency, "originalCurrency", "true", "false", :default_value => nil
    date_time_node :posted_date, "postedDate", :default_value => nil
    date_time_node :user_date, "userDate", :default_value => nil
    date_time_node :available_date, "availableDate", :default_value => nil
    numeric_node :amount, "amount", :default_value => nil
    numeric_node :running_balance_amount, "runningBalanceAmount", :default_value => nil
    numeric_node :sic, "sic", :default_value => nil
    boolean_node :pending, "pending", "true", "false", :default_value => nil
    object_node :categorization, "categorization", :class => Categorization, :default_value => nil
  end

  class BankingTransaction < Transaction
    include XML::Mapping
    use_mapping :_default
  end

  class CreditCardTransaction < Transaction
    include XML::Mapping
    use_mapping :_default
  end

  class InvestmentBankingTransaction < Transaction
    include XML::Mapping
    text_node :banking_transaction_type, "bankingTransactionType", :default_value => nil
    text_node :subaccount_fund_type, "subaccountFundType", :default_value => nil
    text_node :banking_401k_source_type, "banking401KSourceType", :default_value => nil
  end

  class LoanTransaction < Transaction
    include XML::Mapping
    numeric_node :principal_amount, "principalAmount", :default_value => nil
    numeric_node :interest_amount, "interestAmount", :default_value => nil
    numeric_node :escrow_total_amount, "escrowTotalAmount", :default_value => nil
    numeric_node :escrow_tax_amount, "escrowTaxAmount", :default_value => nil
    numeric_node :escrow_insurance_amount, "escrowInsuranceAmount", :default_value => nil
    numeric_node :escrow_pmi_amount, "escrowPmiAmount", :default_value => nil
    numeric_node :escrow_fees_amount, "escrowFeesAmount", :default_value => nil
    numeric_node :escrow_other_amount, "escrowOtherAmount", :default_value => nil
  end

  # TODO - map InvestmentTransaction
  class InvestmentTransaction < Transaction
    include XML::Mapping
    text_node :reversal_institution_transaction_id, "reversalInstitutionTransactionId", :default_value => nil
    text_node :description, "description", :default_value => nil
    text_node :buy_type, "buyType", :default_value => nil
    text_node :income_type, "incomeType", :default_value => nil
    text_node :inv_401k_source, "inv401ksource", :default_value => nil
    text_node :loan_id, "loadId", :default_value => nil
    text_node :options_action_type, "optionsActionType", :default_value => nil
    text_node :options_buy_type, "optionsBuyType", :default_value => nil
    text_node :options_sell_type, "optionsSellType", :default_value => nil
    text_node :position_type, "positionType", :default_value => nil
    text_node :related_institution_trade_id, "relatedInstitutionTradeId", :default_value => nil
    text_node :related_options_trans_type, "relatedOptionsTransType", :default_value => nil
    text_node :secured_type, "securedType", :default_value => nil
    text_node :sell_reason, "sellReason", :default_value => nil
    text_node :sell_type, "sellType", :default_value => nil
    text_node :subaccount_from_type, "subaccountFromType", :default_value => nil
    text_node :subaccount_fund_type, "subaccountFundType", :default_value => nil
    text_node :subaccount_security_type, "subaccountSecurityType", :default_value => nil
    text_node :subaccount_to_type, "subaccountToType", :default_value => nil
    text_node :transfer_action, "transferAction", :default_value => nil
    text_node :unit_type, "unitType", :default_value => nil
    text_node :cusip, "cusip", :default_value => nil
    text_node :symbol, "symbol", :default_value => nil
    text_node :unit_action, "unitAction", :default_value => nil
    text_node :options_security, "optionsSecurity", :default_value => nil
    date_time_node :trade_date, "tradeDate", :default_value => nil
    date_time_node :settle_date, "settleDate", :default_value => nil
    numeric_node :accrued_interest_amount, "accruedInterestAmount", :default_value => nil
    numeric_node :average_cost_basis_amount, "averageCostBasisAmount", :default_value => nil
    numeric_node :commission_amount, "commissionAmount", :default_value => nil
    numeric_node :denominator, "denominator", :default_value => nil
    date_time_node :payroll_date, "payrollDate", :default_value => nil
    date_time_node :purchase_date, "purchaseDate", :default_value => nil
    numeric_node :gain_amount, "gainAmount", :default_value => nil
    numeric_node :fees_amount, "feesAmount", :default_value => nil
    numeric_node :fractional_units_cash_amount, "fractionalUnitsCashAmount", :default_value => nil
    numeric_node :load_amount, "loadAmount", :default_value => nil
    numeric_node :loan_interest_amount, "loadInterestAmount", :default_value => nil
    numeric_node :loan_principal_amount, "loanPrincipalAmount", :default_value => nil
    numeric_node :markdown_amount, "markdownAmount", :default_value => nil
    numeric_node :markup_amount, "markupAmount", :default_value => nil
    numeric_node :new_units, "newUnits", :default_value => nil
    numeric_node :numerator, "numerator", :default_value => nil
    numeric_node :old_units, "oldUnits", :default_value => nil
    numeric_node :penatly_amount, "penaltyAmount", :default_value => nil
    boolean_node :prior_year_contribution, "priorYearContribution", :default_value => nil
    numeric_node :shares_per_contract, "sharesPerContract", :default_value => nil
    numeric_node :state_withholding, "stateWithholding", :default_value => nil
    numeric_node :total_amount, "totalAmount", :default_value => nil
    numeric_node :taxes_amount, "taxesAmount", :default_value => nil
    boolean_node :tax_exmpty, "taxExmpty", :default_value => nil
    numeric_node :unit_price, "unitPrice", :default_value => nil
    numeric_node :units, "units", :default_value => nil
    numeric_node :withholding_amount, "withholdingAmount", :default_value => nil
    numeric_node :options_shares_per_contract, "optionsSharesPerContract", :default_value => nil
  end

  class RewardsTransaction < Transaction
    include XML::Mapping
    use_mapping :_default
  end

  class TransactionList
    include XML::Mapping
    array_node :banking_transactions, "BankingTransaction", :class => BankingTransaction, :default_value => nil
    array_node :credit_card_transactions, "CreditCardTransaction", :class => CreditCardTransaction, :default_value => nil
    array_node :investment_banking_transactions, "InvestmentBankingTransaction", :class => InvestmentBankingTransaction, :default_value => nil
    array_node :loan_transactions, "LoanTransaction", :class => LoanTransaction, :default_value => nil
    array_node :investment_transactions, "InvestmentTransaction", :class => InvestmentTransaction, :default_value => nil
    array_node :rewards_transactions, "RewardsTransaction", :class => RewardsTransaction, :default_value => nil
  end 
end