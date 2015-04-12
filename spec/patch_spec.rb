require 'spec_helper'

describe Onboard::Patch do
  before do
    @pdir = '/tmp/onboard/test/patches'
    @patch = Onboard::Patch.new(@pdir)
  end

  it 'creates a directory' do
    @patch.patch_dir
    expect(File).to exist(@pdir)
  end
end
