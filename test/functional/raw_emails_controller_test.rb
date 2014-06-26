require 'test_helper'

class RawEmailsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => RawEmail.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    RawEmail.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    RawEmail.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to raw_email_url(assigns(:raw_email))
  end

  def test_edit
    get :edit, :id => RawEmail.first
    assert_template 'edit'
  end

  def test_update_invalid
    RawEmail.any_instance.stubs(:valid?).returns(false)
    put :update, :id => RawEmail.first
    assert_template 'edit'
  end

  def test_update_valid
    RawEmail.any_instance.stubs(:valid?).returns(true)
    put :update, :id => RawEmail.first
    assert_redirected_to raw_email_url(assigns(:raw_email))
  end

  def test_destroy
    raw_email = RawEmail.first
    delete :destroy, :id => raw_email
    assert_redirected_to raw_emails_url
    assert !RawEmail.exists?(raw_email.id)
  end
end
