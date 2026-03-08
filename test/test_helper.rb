ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    set_fixture_class "datapass/hr_ssns": Datapass::HrSsn
    set_fixture_class "datapass/employee_details": Datapass::EmployeeDetail
    set_fixture_class "datapass/hr_personals": Datapass::HrPersonal
    set_fixture_class "datapass/identifications": Datapass::Identification
    set_fixture_class "datapass/idmgmts": Datapass::Idmgmt
    set_fixture_class "datapass/jtc_positions": Datapass::JtcPosition
    set_fixture_class "datapass/new_hires": Datapass::NewHire
    set_fixture_class "organization/locations": Organization::Location

    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
