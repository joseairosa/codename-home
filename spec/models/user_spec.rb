require 'spec_helper'

describe User do
  let(:auth) { OmniAuth.config.mock_auth[:facebook] }

  describe '.create_or_retrieve' do
    before do
      #allow(described_class).to receive(:find_or_create_by).and_return(user)
    end

    context 'without a user session' do

      subject { described_class.create_or_retrieve(nil, auth) }

      context 'when creating a new user' do
        before do
          expect(described_class).to receive(:find_by_account)
          expect(described_class).to receive(:create!).with(no_args)
        end

        it { expect(subject).to be_true }
      end

      context 'when retrieving a new user' do
        before do
          expect(described_class).to receive(:find_by_account)
          expect(described_class).to_not receive(:create!).with(no_args)
        end

        it { expect(subject).to be_true }
      end
    end

    #context 'with a user session' do
    #
    #  subject { described_class.create_or_retrieve(nil, auth) }
    #
    #  context 'when creating a new user' do
    #    before do
    #      allow(described_class).to receive(:find_by_facebook_uid).and_return(nil)
    #    end
    #
    #    it {
    #      expect(described_class).to receive(:find_by_facebook_uid).with(anything)
    #      expect(described_class).to receive(:create).with(no_args)
    #      expect(user).to receive(:link_facebook)
    #
    #      expect(subject).to be_true
    #    }
    #  end
    #
    #  context 'when retrieving a new user' do
    #    before do
    #      allow(described_class).to receive(:find_by_facebook_uid).and_return(user)
    #
    #      expect(described_class).to receive(:find_by_facebook_uid).with(anything)
    #      expect(described_class).to_not receive(:create).with(anything)
    #      expect(user).to_not receive(:link_facebook).with(anything)
    #    end
    #
    #    it { expect(subject).to eq user }
    #  end
    #end
  end
end
