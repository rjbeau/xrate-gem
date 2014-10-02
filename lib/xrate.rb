$:.unshift File.dirname(__FILE__)

require "xrate/version"
require "xrate/error"

# XRate
# Provides an interface to the GoCoin Xrate backend web service.
# Xrate is not a public facing web service and is intended only for internal
# consumption by GoCoin applications.
#
# @example
#
#     require 'xrate'
#     Xrate.url = "http://xrate.gocoin.com"
#     Xrate.username = "user"
#     Xrate.password = "password"
#     rates = Xrate::Rates.get
#
module Xrate
  autoload :Config,     'xrate/config'
  autoload :Connection, 'xrate/connection'
  autoload :Request,    'xrate/request'

  extend Connection

  # Can only be called before the connection to make a request.
  def self.enable_faraday_logger
    connection.response :logger
  end

  def self.config
    @_config ||= Config.new
  end

  # Performs a request to get exchange rates from the GoCoin Xrate backend
  # service. This is not a public facing web service, and is intended to be
  # consumed internally by GoCoin applications.
  #
  def self.rates(base="USD")
    response = connection.get "/rates?base=#{base}"
    response.body
  end

  def self.currency_pair(pair, base_price, price_depth=false)
    begin
      if base_price.nil?
        response = connection.get "/rates?currency_pair=#{pair}"
      else
        if price_depth
          response = connection.get "/rates?currency_pair=#{pair}&amount=#{base_price}&price_depth=true"
        else
          response = connection.get "/rates?currency_pair=#{pair}&amount=#{base_price}"
        end
      end
      response.body
    rescue
      { 'timestamp' => Time.now.utc, 'currency_pair' => pair, 'rates' => { pair.to_s => nil } }
    end
  end
end
