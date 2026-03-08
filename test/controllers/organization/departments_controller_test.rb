require "test_helper"

class Organization::DepartmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization_department = organization_departments(:one)
  end

  test "should get index" do
    get organization_departments_url
    assert_response :success
  end

  test "should get new" do
    get new_organization_department_url
    assert_response :success
  end

  test "should create organization_department" do
    assert_difference("Organization::Department.count") do
      post organization_departments_url, params: { organization_department: { name: @organization_department.name, organization_id: @organization_department.organization_id, updated_by_id: @organization_department.updated_by_id } }
    end

    assert_redirected_to organization_department_url(Organization::Department.last)
  end

  test "should show organization_department" do
    get organization_department_url(@organization_department)
    assert_response :success
  end

  test "should get edit" do
    get edit_organization_department_url(@organization_department)
    assert_response :success
  end

  test "should update organization_department" do
    patch organization_department_url(@organization_department), params: { organization_department: { name: @organization_department.name, organization_id: @organization_department.organization_id, updated_by_id: @organization_department.updated_by_id } }
    assert_redirected_to organization_department_url(@organization_department)
  end

  test "should destroy organization_department" do
    assert_difference("Organization::Department.count", -1) do
      delete organization_department_url(@organization_department)
    end

    assert_redirected_to organization_departments_url
  end
end
