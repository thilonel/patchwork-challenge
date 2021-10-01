require 'net/http'
require 'json'

class NomicsClient
  def list(ticker_names)
    uri = URI("#{api_url}/currencies/ticker?key=#{api_key}&ids=#{ticker_names.join(",")}")
    JSON.parse(Net::HTTP.get(uri))
  end

  private

  def api_url
    @api_url ||= ENV["NOMICS_API_URL"]
  end

  def api_key
    @api_key ||= ENV["NOMICS_API_KEY"]
  end
end
