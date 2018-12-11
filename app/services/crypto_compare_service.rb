class CryptoCompareService
  # BUILDING CRYPTOCURRENCIES HASH TO FETCH TO BUILD SEEDS AND FETCH TO API LATER

  # IF YOU WANNA ADD A CRYPTOCURRENCY JUST ADD TICKER_NAME WITH A COMMA TO THE HASH

  # AND TICKER_CODE AS VALUE

  CRYPTO_HASH = {
    Bitcoin: "BTC",
    Cardano: "ADA",
    Dignity: "DIG",
    Litecoin: "LTC",
    Bitcoincash: "BCH",
    Ethereum: "ETH",
    Ethereumclassic: "ETC",
    Ripple: "XRP",
    Basicattentiontoken: "BAT",
    Icon: "ICX",
    Vechain: "VET",
    Stellar: "XLM",
    Ravencoin: "RVN",
    Tron: "TRX",
    Nano: "NANO",
    Monero: "XMR",
    Binance: "BNB",
    Dogecoin: "DOGE",
    Qtum: "QTUM",
    Lisk: "LSK",
    Waves: "WAVES",
    Zcash: "ZEC",
    Siacoin: "SC",
    Augur: "REP"
  }

  FIAT_CURRENCIES = "USD"

  def initialize
    # initializing with empty string that will be filled with tickers
    @crypto_string_with_tickers = ""

    # initializing with empty array that will be filled with names
    @crypto_array_with_names = []

    # base url for get requests with multi currencies and current prices
    @base_url_current_prices = "https://min-api.cryptocompare.com/data/pricemultifull"

    # base url for get requests for historical data
    @base_url_historical_prices = "https://min-api.cryptocompare.com/data/histoday"

    # base url for get requests for latest news
    @base_url_current_news = "https://min-api.cryptocompare.com/data/v2/news/?lang=EN"

    # base url for get requests for top10 traded
    # be careful because the minium number for request is 10 with a max 100
    # since we only need the top5 i left the limit=10 in the base url
    @base_url_top_traded = "https://min-api.cryptocompare.com/data/top/totalvolfull?limit=10"

    @api_key = ENV['CRYPTO_COMPARE_API_KEY']
  end

  def call_current_prices
    # call the previous method
    hash_to_string_and_array

    query_params = {
      fsyms: @crypto_string_with_tickers,
      tsyms: FIAT_CURRENCIES,
      api_key: @api_key
    }
    # Transform the ex string "BTC,ETH,XRP," into "BTC,ETH,XRP"
    @crypto_string_with_tickers = @crypto_string_with_tickers.chomp(",")

    # Transform the crypto string into a crypto array with tickers ex: ["BTC","ETH","XRP"]
    crypto_array_with_tickers = @crypto_string_with_tickers.split(",")

    # Building the API GET Request and Parsing the Response
    response = RestClient.get(@base_url_current_prices, {params: query_params})

    response_parsed = JSON.parse(response)
    # Empty hash to build an hash of hashes
    crypto_seeds_hash = {}

    # THIS RETURNS AN HASH LIKE THIS {btc: 3017.24, eth: 3014.24}
    crypto_array_with_tickers.each do |crypto|
      crypto_seeds_hash[crypto] = response_parsed["RAW"][crypto][FIAT_CURRENCIES]["PRICE"]
    end

    # THIS WILL RETURN AN HASH OF HASHES LIKE THIS
    # {"Bitcoin"=>{"BTC"=>3443.67}, "Ethereum"=>{"ETH"=>200.04}}
    Hash[@crypto_array_with_names.zip(crypto_seeds_hash.to_a)].transform_values!{|a| Hash[*a]}
  end

  def call_historical_prices(crypto, days)
    query_params = {
      fsym: crypto,
      tsym: FIAT_CURRENCIES,
      limit: days,
      toTs: Time.new.to_i,
      api_key: @api_key
    }
    response = RestClient.get(@base_url_historical_prices, {params: query_params})
    response_parsed = JSON.parse(response)
    historical_data = response_parsed["Data"]
    historical_data_days_array = []

    historical_data.each do |data|
      historical_data_days_array << data["close"]
    end
    historical_data_days_array
  end

  def call_latest_news
    query_params = {api_key: @api_key}
    response = RestClient.get(@base_url_current_news, {params: query_params})
    JSON.parse(response)["Data"]
  end

  def call_top5_traded
    query_params = {
      tsym: FIAT_CURRENCIES,
      api_key: @api_key
    }

    crypto_top_5_hash = {}
    response = RestClient.get(@base_url_top_traded, {params: query_params})
    JSON.parse(response)["Data"].first(5).each do |crypto|
      crypto_top_5_hash[crypto["CoinInfo"]["FullName"]] = crypto["CoinInfo"]["Name"]
    end
    # this will return something like this
    # {:Bitcoin=>"BTC", :Ethereum=>"ETH", :EOS=>"EOS", :XRP=>"XRP", :ZCash=>"ZEC"}
    crypto_top_5_hash
  end

  def call_top5_winners
    # this returns an hash like this
    # {"REP"=>8.108108108108116, "WAVES"=>6.535947712418292, "BNB"=>4.228486646884287, "BAT"=>2.183984116479158, "QTUM"=>1.8749999999999878}
    Hash[top5_winners_and_losers.to_a.reverse].first(5).to_h
  end

  def call_top5_losers
    # this returns an hash like this
    # {"DIG"=>-22.26890756302521, "BCH"=>-4.433786825878439, "ZEC"=>-4.110072323161049, "XLM"=>-3.729401561144838, "LSK"=>-3.361344537815129}
    top5_winners_and_losers.first(5).to_h
  end

  private

  def hash_to_string_and_array
    # Iterate through the crypto_hash
    CRYPTO_HASH.each do |key, value|
      # Build a string with all cryptocurrency tickers "BTC,ETH"
      @crypto_string_with_tickers << "#{value},"
      # Build an array with all cryptocurrency names ["Bitcoin", "Ethereum"]
      @crypto_array_with_names << key.to_s
    end
  end

  def top5_winners_and_losers
    hash_to_string_and_array
    @crypto_array_with_tickers = @crypto_string_with_tickers.split(",")

    query_params = {
      fsyms: @crypto_string_with_tickers,
      tsyms: FIAT_CURRENCIES,
      api_key: @api_key
    }

    response = RestClient.get(@base_url_current_prices, {params: query_params})
    response_parsed = JSON.parse(response)
    # Empty hash to build an hash of hashes
    top5_hash = {}
    @crypto_array_with_tickers.each do |crypto|
      top5_hash[crypto] = response_parsed["RAW"][crypto][FIAT_CURRENCIES]["CHANGEPCTDAY"]
    end
    top5_hash.sort_by {|_key, value| value}.to_h
  end

end