require 'spec_helper'

describe User do
  let(:auth) { OmniAuth.config.mock_auth[:facebook] }

  describe '.create_or_retrieve' do
    before do
    end

    context 'without a user session' do

      subject { described_class.create_or_retrieve(nil, auth) }

      context 'when creating a new user' do
        before do

        end

        it {
          expect(described_class).to receive(:find_by_account)
          expect(subject).to be_a User
        }
      end

      context 'when retrieving a new user' do
        before do

        end

        it {
          expect(described_class).to receive(:find_by_account)
          expect(subject).to be_a User
        }
      end
    end
  end
end
