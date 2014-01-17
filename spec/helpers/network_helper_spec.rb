require 'spec_helper'

describe NetworkHelper do

  before do
    allow(helper).to receive(:app_url).and_return('http://localhost:3000')
  end

  describe '#callback_url' do

    context 'when dealing with facebook' do
      subject { helper.callback_url(:facebook) }

      it { expect(subject).to be_nil }
    end

    context 'when dealing with instagram' do
      subject { helper.callback_url(:instagram) }

      it { expect(subject).to eq 'https://api.instagram.com/oauth/authorize/?client_id=123123123123&redirect_uri=http://localhost:3000/auth/instagram/callback&response_type=code' }
    end

    context 'when dealing with foursquare' do
      subject { helper.callback_url(:foursquare) }

      it { expect(subject).to eq 'https://foursquare.com/oauth2/authenticate/?client_id=098765432111&response_type=code&redirect_uri=http://localhost:3000/auth/foursquare/callback' }
    end

    context 'when dealing any other option' do
      subject { helper.callback_url(:amezeballs) }

      it { expect(subject).to be_nil }
    end
  end
end
