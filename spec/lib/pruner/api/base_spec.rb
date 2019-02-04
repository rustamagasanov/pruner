# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pruner::App do
  def app
    described_class
  end

  describe '/undefined_route' do
    it 'responds with 404' do
      get '/undefined_route'
      expect(last_response.status).to eql(404)
    end
  end
end
