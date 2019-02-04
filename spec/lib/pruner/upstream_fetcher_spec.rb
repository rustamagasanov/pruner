# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pruner::UpstreamFetcher do
  describe '.call' do
    it 'raises error if upstream name is not a String' do
      expect { described_class.call({}) }.to raise_exception(
        ArgumentError, "'upstream_name' must be a String"
      )
    end

    it 'returns parsed response is upstream fetch was successful' do
      VCR.use_cassette(:upstream_status_200) do
        expect(described_class.call('input')).to be_a(Array)
      end
    end

    it 'raises error is upstream does not exist' do
      VCR.use_cassette(:upstream_status_404) do
        expect { described_class.call('abc') }.to raise_exception(
          Pruner::Errors::NotFound, "Failed to find an upstream 'abc'"
        )
      end
    end

    context 'when upstream responds with 500' do
      let(:response) { double }

      before do
        allow(HTTP).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow_any_instance_of(Object).to receive(:sleep)
      end

      it "retries #{ENV['UPSTREAM_FETCH_ATTEMPTS']} times, raises after" do
        expect(HTTP).to receive(:get).with("#{ENV['UPSTREAM_BASE_URL']}input").exactly(5).times
        expect { described_class.call('input') }.to raise_error(
          StandardError, "Failed to fetch an upstream after #{ENV['UPSTREAM_FETCH_ATTEMPTS']} attempts"
        )
      end
    end
  end
end
