require 'net/http'
require 'json'
require 'bigdecimal'
require 'bigdecimal/util'

class NomicsClient
  CURRENCIES_TICKER_PATH = "currencies/ticker".freeze

  def initialize(api_host: ENV["NOMICS_API_HOST"], api_key: ENV["NOMICS_API_KEY"])
    if api_host.nil? || api_host.empty? || api_key.nil? || api_key.empty?
      raise ArgumentError.new("invalid nomics client config")
    end

    @api_host = api_host
    @api_key = api_key
  end

  def list(tickers, fields: nil, convert: "USD")
    uri = build_uri(CURRENCIES_TICKER_PATH, query_params: { "ids" => tickers.join(","), "convert" => convert })

    response = nil
    10.times do
      response = Net::HTTP.get_response(uri)
      break if response.code != "429" # Too Many Request
      sleep 1 # API Rate limit for free accounts is 1 request / sec
    end

    raise Error.new(response.code, response.body) if response.code != "200"

    currencies = JSON.parse(response.body)

    if fields.nil?
      currencies
    else
      currencies.map { |currency| currency.delete_if { |field_name, _| !fields.include?(field_name) } }
    end
  end

  def price(of:, as:)
    currencies_info = list([of, as], fields: %w[id price])

    currency = currencies_info.find { |currency_info| currency_info["id"] == of }
    target_currency = currencies_info.find { |currency_info| currency_info["id"] == as }

    currency["price"].to_d / target_currency["price"].to_d
  end

  private

  attr_reader :api_host, :api_key

  def build_uri(resource_path, query_params: {})
    query_params["key"] = api_key
    URI::HTTPS.build(host: api_host, path: "/v1/#{resource_path}", query: URI.encode_www_form(query_params))
  end

  class Error < StandardError
    attr_reader :code, :message

    def initialize(code, message)
      @code = code
      @message = message
    end
  end
end
