require 'uri'
include REXML
class MasterPassController < ApplicationController
  
  before_action :setup
  after_action :save_session_data
  rescue_from RuntimeError, with: :set_error_message
  
  # Controller Actions
  def index
    @data = session['data'] = MasterpassData.new("config.yml")
  end
  
  def oauth
    process_parameters
    get_request_token
  end
  
  def oauthshoppingcart
    post_shopping_cart
  end
  
  def oauthcallback
    handle_oauth_callback
  end
  
  def accesstoken
    get_access_token
  end
  
  def oauthcheckout
    get_checkout_data
  end
  
  def oauthpostback
    log_transaction
  end
  
  def pairingtoken
    process_parameters if params['checkout'] != "true"
    get_pairing_token
  end
  
  def merchantinitialization
    post_merchant_init
  end
  
  def pairingcallback
    handle_pairing_callback
  end
  
  def precheckout
    get_request_token
    post_shopping_cart
    get_precheckout_data
  end
  
  def expresscheckout
    post_shopping_cart
    post_express_checkout
  end
  
  def cart
    process_parameters
    get_request_token
    post_shopping_cart
  end
  
  def cartcallback
    handle_oauth_callback
    get_access_token
    get_checkout_data
    render :cart
  end
  
  def cartpostback
    log_transaction
  end
  
  #JSON callback 
  def pairingconfiguration
    @data.pairing_data_types = params['dataTypes'].split(',')
    render :json => @data.to_json
  end
  
  private
  
  def setup
    # NOTE: in an actual production application, this type of session data should be stored in a 
    # database. To keep our sample application database-type agnostic, we are storing this in a rails-cached session for example purposes only (note the config/initializers/session_store.rb initializer has been set to :cache_store in order to have a session larger than 4k)
    session['data'] == nil ? @data = session['data'] = MasterpassData.new("config.yml") : @data = session['data']
    @service = Mastercard::Masterpass::MasterpassService.new(@data.consumer_key, generate_private_key, @data.callback_domain, Mastercard::Common::SANDBOX)
    # create an unreferenced MasterpassDataMapper to include the mapping namespaces of our DTO's
    MasterpassDataMapper.new
    # clear any previous error messages
    @data.error_message = nil
    # get the current host name for dynamic url generation
    @data.callback_domain = @host_name = request.protocol + request.host || "http://projectabc.com"
  end
  
  def save_session_data
    session['data'] = nil
    session['data'] = @data
  end
  
  def set_error_message(error)
    @data.error_message = error.to_s
    render
  end
  
  def generate_private_key
    OpenSSL::PKCS12.new(File.open(@data.keystore_path),@data.keystore_password).key
  end
  
  def process_parameters
    @data.xml_version = params['xmlVersionDropdown']
    @data.shipping_suppression = params['shippingSuppressionDropdown']
    @data.rewards = params['rewardsDropdown']
    @data.auth_level_basic = params['authenticationCheckBox'] == nil ? false : true
    @data.redirect_shipping_profiles = params['shippingProfileDropdown']
    @data.accepted_cards = params['acceptedCardsCheckbox'].join(",") if params['acceptedCardsCheckbox']
    @data.accepted_cards << "," << params['privateLabelText'] if params['privateLabelText'] != nil && params['privateLabelText'].length > 0
  end
  
  def save_connection_header
    @data.auth_header = @service.auth_header
    @data.encoded_auth_header = URI.escape(@data.auth_header)
    @data.signature_base_string = @service.signature_base_string
  end
  
  protected
  
  def get_request_token
    @data.request_token_response = @service.get_request_token(@data.request_url, @data.callback_domain)
    @data.request_token = @data.request_token_response.oauth_token
    save_connection_header
  end
  
  def post_shopping_cart
    file = File.read(File.join('resources', 'shoppingCart.xml'))
    @data.shopping_cart_request = ShoppingCartRequest.from_xml(file)
    @data.shopping_cart = @data.shopping_cart_request.shoppingCart
    @data.shopping_cart.shoppingCartItem.each do |i|
      i.description = i.description[0..99] if i.description.length > 100
      i.description = i.description[0..98] if i.description.last == "&"
    end
    @data.shopping_cart_request.oAuthToken = @data.request_token
    @data.shopping_cart_request.originUrl = @data.callback_domain
    @data.shopping_cart_response = ShoppingCartResponse.from_xml(@service.post_shopping_cart_data(@data.shopping_cart_url, @data.shopping_cart_request.to_xml_s)) 
  end
  
  def handle_oauth_callback
    @data.request_token = params['oauth_token']
    @data.verifier = params['oauth_verifier']
    @data.checkout_resource_url = params['checkout_resource_url']
    handle_pairing_callback if params['pairing_token'] && params['pairing_verifier']
  end
  
  def get_access_token
    @data.access_token_response = @service.get_access_token(@data.access_url, @data.request_token, @data.verifier)
    @data.access_token = @data.access_token_response.oauth_token
    save_connection_header
  end
  
  def get_checkout_data
    @data.checkout = Checkout.from_xml(@service.get_payment_shipping_resource(@data.checkout_resource_url, @data.access_token));
    save_connection_header
  end
  
  def log_transaction
    order_amount = 1000;
    if (@data.shopping_cart)
      order_amount = @data.shopping_cart.subtotal
      order_amount = order_amount + @data.tax + @data.shipping
    end
    approval_code = "sample"
    if (!approval_code)
      approval_code = "UNAVBL"
    end
    merchant_transactions = MerchantTransactions.new
    merchant_transaction = MerchantTransaction.new(@data.checkout.transactionId,@data.consumer_key,"USD",order_amount,Time.now,"Success",approval_code,@data.precheckout_transaction_id,@data.express_checkout_indicator)
    merchant_transactions << merchant_transaction
    @data.merchant_transactions = merchant_transactions
    xml = merchant_transactions.to_xml
    # we need to pluralize the child MerchantTransaction node name to adhere to the XML schema
    XPath.first(xml, "//MerchantTransaction").name = "MerchantTransactions"
    @data.post_transaction_sent_xml = xml.to_s
    response_xml = ""
    Document.new(@service.post_checkout_transaction(@data.postback_url, xml), {:compress_whitespace => :all}).write(response_xml, 2)
    @data.post_transaction_received_xml = response_xml
    # and change the child MerchantTransaction node name back to singular for proper xml mapping if we want to get a Ruby object back from the xml
    
    # XPath.first(response_xml, "//MerchantTransactions/*[not(root)]").name = "MerchantTransaction"
    # MerchantInitializationResponse.from_xml(response_xml.to_s)
    save_connection_header
  end
  
  def get_pairing_token
    @data.pairing_token = @service.get_pairing_token(@data.request_url, @data.callback_domain).oauth_token
    save_connection_header
  end
  
  def post_merchant_init
    @data.merchant_init_request = MerchantInitializationRequest.new(@data.pairing_token, nil, @data.callback_domain)
    @data.merchant_init_response = MerchantInitializationResponse.from_xml(@service.post_merchant_init_data(@data.merchant_init_url, @data.merchant_init_request.to_xml_s))
    save_connection_header
  end
  
  def handle_pairing_callback
    @data.pairing_token = params['pairing_token']
    @data.pairing_verifier = params['pairing_verifier']
    @data.long_access_token_response = @service.get_long_access_token(@data.access_url, @data.pairing_token, @data.pairing_verifier)
    # NOTE: we are storing the Long Access Token in a cookie for example purposes only. In a production environment this would be stored in the user's database record.
    @data.long_access_token = cookies["longAccessToken"] = @data.long_access_token_response.oauth_token
  end
  
  def get_precheckout_data
    @data.precheckout_request = PrecheckoutDataRequest.new(PairingDataTypes.new)
    @data.pairing_data_types.each do |d|
      @data.precheckout_request.pairingDataTypes << PairingDataType.new(d)
    end
    logger.debug "pairing data types: #{@data.precheckout_request.pairingDataTypes}"
    response = @service.get_precheckout_data(@data.precheckout_url, @data.precheckout_request.to_xml_s, @data.long_access_token)
    logger.debug response
    @data.precheckout_response = PrecheckoutDataResponse.from_xml(response)
    #logger.debug "precheckout_response: \n#{@data.precheckout_response.to_xml_s}"
    precheckout_data = @data.precheckout_data = @data.precheckout_response.precheckoutData
    logger.debug precheckout_data.inspect
    # NOTE: we are storing the Long Access Token in a cookie for example purposes only. In a production environment this would be stored in the user's database record.
    @data.long_access_token = cookies["longAccessToken"] = @data.precheckout_response.longAccessToken
    @data.wallet_name = precheckout_data.walletName
    @data.consumer_wallet_id = precheckout_data.consumerWalletId
    @data.precheckout_transaction_id = precheckout_data.precheckoutTransactionId
    if precheckout_data.shippingAddresses
      precheckout_data.shippingAddresses.each do |a|
        @data.precheckout_shipping_id = a.addressId
      end
    end
    if precheckout_data.cards
      precheckout_data.cards.each do |c|
        @data.precheckout_card_id = c.cardId
      end
    end
    @data.precheckout_transaction_id = precheckout_data.precheckoutTransactionId
    save_connection_header
  end
  
  def post_express_checkout
    cookies["longAccessToken"] = @data.long_access_token
    @data.precheckout_card_id = params['cardSubmit'] if params['cardSubmit']
    @data.precheckout_shipping_id = params['addressSubmit'] if params['addressSubmit']
    @data.express_checkout_request = ExpressCheckoutRequest.new(@data.checkout_identifier, @data.precheckout_transaction_id, "USD", @data.shopping_cart.subtotal + @data.tax + @data.shipping, @data.precheckout_card_id, @data.precheckout_shipping_id, "", @data.wallet_name, false, @host_name,nil)
    @data.express_checkout_response = ExpressCheckoutResponse.from_xml(@service.get_express_checkout_data(@data.express_checkout_url, @data.express_checkout_request.to_xml_s, @data.long_access_token))
    @data.express_checkout_response.errors ? (@data.express_checkout_response.errors.map{|e| e.source == '3DS Needed'} ? @data.express_security_required = true : @data.express_security_required = false) : @data.express_security_required = false
    @data.checkout = @data.express_checkout_response.checkout
    @data.express_checkout_indicator = true
    @data.long_access_token = cookies['longAccessToken'] = @data.express_checkout_response.longAccessToken
    save_connection_header   
  end
  
end
