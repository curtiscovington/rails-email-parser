require 'test_helper'

class RawEmailTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert RawEmail.new.valid?
  end
end
