RSpec.describe NomicsClient do
  shared_examples "rate limit handling" do
    it "returns a successful result even if the requests are sent right after each other" do
      action
      expect { action }.not_to raise_error
      expect { action }.not_to raise_error
    end
  end

  describe "#list" do
    subject(:list) { client.list(tickers, fields: fields, convert: convert) }
    let(:client) { described_class.new }
    let(:tickers) { ["BTC"] }
    let(:fields) { nil }
    let(:convert) { nil }

    context "when passing valid ticker names" do
      let(:tickers) { %w[BTC, ETH] }

      include_examples "rate limit handling" do
        def action
          client.list(tickers, fields: fields, convert: convert)
        end
      end

      it "returns everything from the API for that cryptocurrency" do
        expect(list.size).to eq 2

        # We have no guarantee on the order of the currencies.
        list.sort_by! { |currency_info| currency_info["id"] }
        expect(list[0]["currency"]).to eq "BTC"
        expect(list[1]["currency"]).to eq "ETH"
      end

      context "when passing the fields argument" do
        let(:fields) { %w[circulating_supply max_supply name symbol price] }

        it "filters the response, returning only the specified fields" do
          expect(list.size).to eq 2

          # We have no guarantee on the order of the currencies
          list.sort_by! { |currency_info| currency_info["name"] }

          expect(list[0]["currency"]).to eq nil # because it was not requested
          expect(list[0]["name"]).to eq "Bitcoin"
          expect(list[0]["max_supply"]).to eq "21000000"
          expect(list[0]["circulating_supply"].to_i).to be_between(18_831_606, 21_000_000)
          expect(list[0]["symbol"]).to eq "BTC"
          expect(list[0]["price"].to_f >= 0.0).to eq true

          expect(list[1]["currency"]).to eq nil # because it was not requested
          expect(list[1]["name"]).to eq "Ethereum"
          expect(list[1]["max_supply"]).to eq nil # because it's not present in the response
          expect(list[1]["circulating_supply"].to_i >= 117_753_182).to eq true
          expect(list[1]["symbol"]).to eq "ETH"
          expect(list[1]["price"].to_f > 0.0).to eq true
        end

        context "when the field passed does not exist in the response" do
          let(:fields) { ["foobarbaz"] }

          it "returns a successful result but the field will be absent" do
            # We can't validate the fields input as we don't know all of the possibilities.
            # If we can get all the possible field names, we should raise an error to detect typos and such.
            # Moreover, not all of the fields are present on all the currencies,
            # so we can't validate against the returned fields either.
            expect(list[0]["foobarbazbaz"]).to eq nil
          end
        end
      end

      context "when passing the convert argument" do
        it "returns all the monetary values in the specified fiat currency" do
          price_in_usd = client.list(["BTC"])[0]["price"]
          price_in_zar = client.list(["BTC"], convert: "ZAR")[0]["price"]
          expect(price_in_usd).not_to eq price_in_zar
        end
      end
    end
  end

  describe "#price" do
    subject(:price) { client.price(of: currency, as: target_currency) }
    let(:client) { described_class.new }

    context "when passing valid arguments" do
      let(:currency) { "BTC" }
      let(:target_currency) { "ETH" }

      it "returns the price of the currency expressed in the target_currency using their dollar value" do
        expect(price).to be_between(1, 30)
      end

      include_examples "rate limit handling" do
        def action
          client.price(of: currency, as: target_currency)
        end
      end
    end
  end
end
