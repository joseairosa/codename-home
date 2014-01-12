require 'spec_helper'

describe User do

  let(:auth) { OmniAuth.config.mock_auth[:facebook] }

  it { expect(described_class).to embed_many(:networks) }
  it { expect(described_class).to have_index_for('network.uid' => 1) }
  it { expect(described_class).to have_index_for(email: 1).with_options(unique: true, sparse: true) }
  it { expect(described_class).to have_field(:email) }

  describe '.create_or_retrieve' do

    before do
      expect(described_class).to receive(:find_by_account).and_call_original
    end

    context 'without a user session' do

      subject { described_class.create_or_retrieve(nil, auth) }

      context 'when creating a new user' do
        it { expect(subject).to be_a User }
      end

      context 'when retrieving an existing user' do
        before do
          expect(described_class).to_not receive(:create!)
        end

        it {
          user = User.create
          user.link_account(auth)
          expect(subject).to eq user
          expect(user.networks.first.uid).to eq auth.uid
        }
      end
    end

    context 'with a user session' do

      let(:session) { { user_id: '12345' } }

      subject { described_class.create_or_retrieve(session[:user_id], auth) }

      context 'when setting a network' do

        before do
          expect(described_class).to_not receive(:create!)
        end

        it {
          user = User.create
          user.link_account(auth)
          expect(subject).to eq user
          expect(user.networks.first.uid).to eq auth.uid
        }
      end
    end
  end
end
