require 'spec_helper'

module Rmega
  describe Storage do

    describe '#stats' do

      let(:session) { Session.new }

      let(:subject) { Storage.new(session) }

      let(:nodes) do
        [{'s' => 10, 't' => 0}, {'t' => 1}, {'s' => 5, 't' => 0}].map do |data|
          Nodes::Factory.build(session, data)
        end
      end

      before do
        allow(subject).to receive(:nodes).and_return(nodes)
      end

      it 'returns a hash with the number of file nodes and the total size' do
        expect(subject.stats).to eq(files: 2, size: 15)
      end
    end
  end
end
