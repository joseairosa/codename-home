require 'spec_helper'

describe Network::Storage do

  it { expect(described_class).to be_embedded_in(:user) }
  it { expect(described_class).to have_field(:provider) }
  it { expect(described_class).to have_field(:uid) }
  it { expect(described_class).to have_field(:name) }
  it { expect(described_class).to have_field(:oauth_token) }
  it { expect(described_class).to have_field(:oauth_expires_at) }
  it { expect(described_class).to have_field(:source) }

end
