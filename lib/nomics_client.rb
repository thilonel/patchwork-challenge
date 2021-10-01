require 'net/http'
require 'json'

class NomicsClient
  def list(tickers, fields: nil, convert: "USD")
    sleep 1
    uri = URI("#{api_url}/currencies/ticker?key=#{api_key}&ids=#{tickers.join(",")}&convert=#{convert}")
    JSON.parse(Net::HTTP.get(uri)).map do |currency|
      currency.delete_if { |k, _| !fields.nil? && !fields.include?(k) }
    end
  end

  private

  def api_url
    @api_url ||= ENV["NOMICS_API_URL"]
  end

  def api_key
    @api_key ||= ENV["NOMICS_API_KEY"]
  end
end
