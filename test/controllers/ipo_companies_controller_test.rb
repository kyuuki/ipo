require 'test_helper'

class IpoCompaniesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ipo_company = ipo_companies(:one)
  end

  test "should get index" do
    get ipo_companies_url
    assert_response :success
  end

  test "should get new" do
    get new_ipo_company_url
    assert_response :success
  end

  test "should create ipo_company" do
    assert_difference('IpoCompany.count') do
      post ipo_companies_url, params: { ipo_company: { apply_from: @ipo_company.apply_from, apply_to: @ipo_company.apply_to, code: @ipo_company.code, listed_at: @ipo_company.listed_at, name: @ipo_company.name, price: @ipo_company.price, rank: @ipo_company.rank } }
    end

    assert_redirected_to ipo_company_url(IpoCompany.last)
  end

  test "should show ipo_company" do
    get ipo_company_url(@ipo_company)
    assert_response :success
  end

  test "should get edit" do
    get edit_ipo_company_url(@ipo_company)
    assert_response :success
  end

  test "should update ipo_company" do
    patch ipo_company_url(@ipo_company), params: { ipo_company: { apply_from: @ipo_company.apply_from, apply_to: @ipo_company.apply_to, code: @ipo_company.code, listed_at: @ipo_company.listed_at, name: @ipo_company.name, price: @ipo_company.price, rank: @ipo_company.rank } }
    assert_redirected_to ipo_company_url(@ipo_company)
  end

  test "should destroy ipo_company" do
    assert_difference('IpoCompany.count', -1) do
      delete ipo_company_url(@ipo_company)
    end

    assert_redirected_to ipo_companies_url
  end
end
