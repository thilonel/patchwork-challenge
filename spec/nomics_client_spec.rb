RSpec.describe NomicsClient do
  describe "#list" do
    subject(:list) { client.list(ticker_names, fields) }
    let(:client) { described_class.new }
    let(:fields) { nil }

    context "when passing valid ticker names" do
      let(:ticker_names) { %w[BTC, ETH] }

      it "returns everything from the API for that cryptocurrency" do
        expect(list.size).to eq 2
        expect(list[0]["currency"]).to eq "BTC"
        expect(list[1]["currency"]).to eq "ETH"
      end

      context "when also passing the fields argument" do
        let(:fields) { %w[circulating_supply max_supply name symbol price] }

        it "filters the response, returning only the specified fields" do
          expect(list.size).to eq 2
          expect(list[0]["currency"]).to eq nil
          expect(list[0]["name"]).to eq "Bitcoin"
          expect(list[0]["max_supply"]).to eq "21000000"
          expect(list[0]["circulating_supply"].to_i).to be_between(18_831_606, 21_000_000)
          expect(list[0]["symbol"]).to eq "BTC"
          expect(list[0]["price"].to_f >= 0.0).to eq true

          expect(list[1]["currency"]).to eq nil
          expect(list[1]["name"]).to eq "Ethereum"
          expect(list[1]["max_supply"]).to eq nil
          expect(list[1]["circulating_supply"].to_i >= 117_753_182).to eq true
          expect(list[1]["symbol"]).to eq "ETH"
          expect(list[1]["price"].to_f > 0.0).to eq true
        end
      end
    end
  end
end
