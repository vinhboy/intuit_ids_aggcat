require 'spec_helper'

describe IntuitIdsAggcat::Client::Services do
  before(:all) do
    path = Pathname.new("spec/config/real_config.yml")
    cfg = YAML::load(ERB.new(File.read(path)).result)
    IntuitIdsAggcat.config(cfg)
  end

  it 'should get financial institutions' do
    institutions = IntuitIdsAggcat::Client::Services.get_institutions
    institutions.should_not be_nil
    institutions[0].name.should_not be_nil
  end

  it 'should get financial institution detail' do
    i = IntuitIdsAggcat::Client::Services.get_institution_detail 14007
    i.name.should == "Bank of America"
    i.special_text.should == "Please enter your Bank of America Online ID and Passcode required for login."
  end

  it 'should setup aggregation with username/password then delete the customer' do
    IntuitIdsAggcat::Client::Services.delete_customer "9cj2hbjfgh47cna72"
    x = IntuitIdsAggcat::Client::Services.discover_and_add_accounts_with_credentials 100000, "9cj2hbjfgh47cna72", { "Banking Userid" => "direct", "Banking Password" => "anyvalue" } 
    x[:discover_response][:response_code].should == "201"
    x[:accounts].should_not be_nil
    x[:accounts].banking_accounts.count.should be > 2
    x = IntuitIdsAggcat::Client::Services.delete_customer "9cj2hbjfgh47cna72"
    x[:response_code].should == "200"
  end

  it 'should setup aggregation with text challenge then delete the customer' do
    IntuitIdsAggcat::Client::Services.delete_customer "9cj2hbjfgh47cna72"
    x = IntuitIdsAggcat::Client::Services.discover_and_add_accounts_with_credentials 100000, "9cj2hbjfgh47cna72", { "Banking Userid" => "tfa_text", "Banking Password" => "anyvalue" } 
    x[:discover_response][:response_code].should == "401"
    x[:discover_response][:challenge_node_id].should_not be_nil
    x[:discover_response][:challenge_session_id].should_not be_nil
    x[:challenge_type].should == "text"
    x[:challenge].challenge.text.should == "Enter your first pet's name:"
    x = IntuitIdsAggcat::Client::Services.challenge_response 100000, "9cj2hbjfgh47cna72", "test", x[:discover_response][:challenge_session_id], x[:discover_response][:challenge_node_id]
    x[:accounts].should_not be_nil
    x[:accounts].banking_accounts.count.should be > 2
    x = IntuitIdsAggcat::Client::Services.delete_customer "9cj2hbjfgh47cna72"
    x[:response_code].should == "200"
  end

  it 'should setup aggregation with choice challenge then delete the customer' do
    IntuitIdsAggcat::Client::Services.delete_customer "9cj2hbjfgh47cna72"
    x = IntuitIdsAggcat::Client::Services.discover_and_add_accounts_with_credentials 100000, "9cj2hbjfgh47cna72", { "Banking Userid" => "tfa_choice", "Banking Password" => "anyvalue" } 
    x[:discover_response][:response_code].should == "401"
    x[:discover_response][:challenge_node_id].should_not be_nil
    x[:discover_response][:challenge_session_id].should_not be_nil
    x[:challenge_type].should == "choice"
    x[:challenge].challenge.text.should == "Which high school did you attend?"
    x = IntuitIdsAggcat::Client::Services.challenge_response 100000, "9cj2hbjfgh47cna72", "test", x[:discover_response][:challenge_session_id], x[:discover_response][:challenge_node_id]
    x[:accounts].should_not be_nil
    x[:accounts].banking_accounts.count.should be > 2
    x = IntuitIdsAggcat::Client::Services.delete_customer "9cj2hbjfgh47cna72"
    x[:response_code].should == "200"
  end

end