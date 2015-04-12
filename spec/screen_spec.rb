require 'spec_helper'

describe Onboard::Screen do
  before do
    @screen = Onboard::Screen.new
  end

  it 'returns 2 items' do
    expect(@screen.size.length).to eq(2)
  end

  it 'returns items of type Integer' do
    @screen.size.each { |x| expect(x).to be_an(Integer) }
  end
end
