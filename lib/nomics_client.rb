require 'net/http'
require 'json'

class NomicsClient
  def list(ticker_names, fields)
    uri = URI("#{api_url}/currencies/ticker?key=#{api_key}&ids=#{ticker_names.join(",")}")
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
