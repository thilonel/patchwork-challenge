RSpec.describe NomicsClient do
  describe "#list" do
    subject(:list) { client.list(ticker_names) }
    let(:client) { described_class.new }

    context "when passing a valid ticker name" do
      let(:ticker_names) { %w[BTC] }

      it "returns everything from the API for that cryptocurrency" do
        expect(list.size).to eq 1
        expect(list.first["currency"]).to eq "BTC"
      end
    end
  end
end
