require 'spec_helper'

describe Onboard::Msg do
  before do
    @message = Onboard::Msg.new('hello')
  end

  it 'prints string with trailing spaces to STDOUT' do
    expect{@message.format}.to output(/^hello\s*/).to_stdout
  end
end
