require 'spec_helper'

module Rototiller
  module Task

    describe EnvCollection do
      context '#allowed_class' do
        it 'allows only EnvVars' do
          expect( described_class.new.allowed_class ).to eql(EnvVar)
        end
      end
    end

  end
end
