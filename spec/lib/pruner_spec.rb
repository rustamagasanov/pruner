# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pruner do
  it { expect(described_class).to respond_to(:env) }
  it { expect(described_class).to respond_to(:root) }
  it { expect(described_class).to respond_to(:logger) }
end
