require 'net/http'
require 'json'
require 'bigdecimal'
require 'bigdecimal/util'

class NomicsClient
  CURRENCIES_TICKER_PATH = "currencies/ticker".freeze

  def list(tickers, fields: nil, convert: "USD")
    sleep 1

    uri = build_uri(CURRENCIES_TICKER_PATH, query_params: { "ids" => tickers.join(","), "convert" => convert })
    response = Net::HTTP.get(uri)
    response_json = JSON.parse(response)

    if fields.nil?
      response_json
    else
      response_json.map { |currency_info| currency_info.delete_if { |field_name, _| !fields.include?(field_name) } }
    end
  end

  def price(of:, as:)
    currencies_info = list([of, as], fields: %w[id price])

    currency = currencies_info.find { |currency_info| currency_info["id"] == of }
    target_currency = currencies_info.find { |currency_info| currency_info["id"] == as }

    currency["price"].to_d / target_currency["price"].to_d
  end

  private

  def build_uri(resource_path, query_params: {})
    query_params["key"] = api_key
    URI::HTTPS.build(host: api_host, path: "/v1/#{resource_path}", query: URI.encode_www_form(query_params))
  end

  def api_host
    @api_host ||= "#{ENV["NOMICS_API_HOST"]}"
  end

  def api_key
    @api_key ||= ENV["NOMICS_API_KEY"]
  end
end
