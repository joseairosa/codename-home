require 'spec_helper'

describe TestController do
  render_views

  before do
    allow(controller).to receive(:app_url).and_return('')
  end

  context 'when a Koala::Facebook::AuthenticationError is found' do
    before do
      allow(controller).to receive(:current_user).and_raise(Koala::Facebook::AuthenticationError.new(400, 'test'))
    end

    it 'should clear session and redirect to root' do
      get :apis
      expect(response).to redirect_to('/')
    end
  end
end