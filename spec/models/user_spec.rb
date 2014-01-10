require 'spec_helper'

describe User do
  let(:auth) {
    double(:auth, {
      provider: 'provider',
      uid: '123123123',
      info: double(:info, name: 'José Airosa'),
      credentials: double(:credentials, token: 'token', expires_at: Time.current.utc)}
    )
  }
  let(:entry) {
    double(:entry, create_facebook: nil)
  }
  let(:storage) {
    double(:storage, first: entry)
  }
  let(:user) {
    User.new
  }

  describe '.create_or_retrieve' do
    before do
      allow(described_class).to receive(:create).and_return(user)
    end

    subject { described_class.create_or_retrieve(auth) }

    context 'when creating a new user' do
      before do
        allow(described_class).to receive(:find_by_facebook_uid).and_return(nil)
      end

      it {
        expect(described_class).to receive(:find_by_facebook_uid).with(anything)
        expect(described_class).to receive(:create).with(no_args)
        expect(user).to receive(:link_facebook)

        expect(subject).to eq user
      }
    end

    context 'when retrieving a new user' do
      before do
        allow(described_class).to receive(:find_by_facebook_uid).and_return(user)

        expect(described_class).to receive(:find_by_facebook_uid).with(anything)
        expect(described_class).to_not receive(:create).with(anything)
        expect(user).to_not receive(:link_facebook).with(anything)
      end

      it { expect(subject).to eq user }
    end
  end
end
