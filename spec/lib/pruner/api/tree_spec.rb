# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pruner::App do
  def app
    described_class
  end

  describe '/tree/:name' do
    it 'responds with 400 for invalid indicator_ids' do
      get '/tree/input', indicator_ids: 1
      expect(last_response.status).to eql(400)
    end

    it 'responds with 404 for unknown upstream' do
      VCR.use_cassette(:upstream_status_404) do
        get '/tree/abc'
        expect(last_response.status).to eql(404)
      end
    end

    context 'when upstream is down' do
      let(:response) { double }

      before do
        allow(HTTP).to receive(:get).and_return(response)
        allow(response).to receive(:code).and_return(500)
        allow_any_instance_of(Object).to receive(:sleep)
      end

      it 'responds with 500' do
        get '/tree/input'
        expect(last_response.status).to eql(500)
      end
    end

    context 'when upstream is up' do
      let(:pruner_instance) { double }
      let(:tree) { double }

      before do
        allow(Pruner::UpstreamFetcher).to receive(:call).and_return(tree)
        allow(Pruner::TreePruner).to receive(:new).and_return(
          pruner_instance
        )
        allow(pruner_instance).to receive(:call)
      end

      it 'responds with 200' do
        get '/tree/input'
        expect(last_response.status).to eql(200)
      end

      it 'passes a tree to the fetcher' do
        expect(Pruner::UpstreamFetcher).to receive(:call).with('abc')
        get '/tree/abc'
      end

      it 'passes a upstream_data and ids to the pruner' do
        expect(Pruner::TreePruner).to receive(:new).with(tree, [1, 2, 3])
        expect(pruner_instance).to receive(:call)
        get '/tree/abc', indicator_ids: [1, 2, 3]
      end
    end
  end
end
