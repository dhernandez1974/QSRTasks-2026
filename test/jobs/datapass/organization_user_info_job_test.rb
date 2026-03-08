require "test_helper"
require "ostruct"

class Datapass::OrganizationUserInfoJobTest < ActiveJob::TestCase
  setup do
    (self.class.respond_to?(:queue_adapter=) ? self.class : ActiveJob::Base).queue_adapter = :test
    @organization = organizations(:one)
    @organization.update!(eid: "12345")
  end

  test "should enqueue DatapassWebhookRouterJob for matching files" do
    s3_client_mock = Object.new
    
    # Mock list_objects_v2
    contents = [
      OpenStruct.new(key: "prod/0001480_DataSource_HR-EmployeeDetails_TopicID_V1_20260308100000000_12345.json.enc"),
      OpenStruct.new(key: "prod/0001480_DataSource_OtherTopic_TopicID_V1_20260308100000000_12345.json.enc")
    ]
    resp = OpenStruct.new(contents: contents, is_truncated: false)
    
    def s3_client_mock.list_objects_v2(args)
      @resp
    end
    s3_client_mock.instance_variable_set(:@resp, resp)

    # Manual mock for Aws::S3::Client.new
    Aws::S3::Client.instance_eval do
      class << self
        alias_method :old_new, :new
        def new(*args)
          @mock_client
        end
        attr_accessor :mock_client
      end
    end
    Aws::S3::Client.mock_client = s3_client_mock

    begin
      assert_enqueued_with(job: Datapass::DatapassWebhookRouterJob) do
        matched = Datapass::OrganizationUserInfoJob.perform_now(organization_ids: [@organization.id], days: 1)
        assert_equal 1, matched
      end
    ensure
      Aws::S3::Client.instance_eval do
        class << self
          alias_method :new, :old_new
          remove_method :old_new
        end
      end
    end
  end

  test "should respect date cutoff" do
    s3_client_mock = Object.new
    
    old_ts = (Time.zone.now - 10.days).strftime("%Y%m%d%H%M%S000")
    contents = [
      OpenStruct.new(key: "prod/0001480_DataSource_HR-EmployeeDetails_TopicID_V1_#{old_ts}_12345.json.enc")
    ]
    resp = OpenStruct.new(contents: contents, is_truncated: false)
    
    def s3_client_mock.list_objects_v2(args)
      @resp
    end
    s3_client_mock.instance_variable_set(:@resp, resp)

    Aws::S3::Client.instance_eval do
      class << self
        alias_method :old_new, :new
        def new(*args)
          @mock_client
        end
        attr_accessor :mock_client
      end
    end
    Aws::S3::Client.mock_client = s3_client_mock

    begin
      assert_no_enqueued_jobs(only: Datapass::DatapassWebhookRouterJob) do
        matched = Datapass::OrganizationUserInfoJob.perform_now(organization_ids: [@organization.id], days: 7)
        assert_equal 0, matched
      end
    ensure
      Aws::S3::Client.instance_eval do
        class << self
          alias_method :new, :old_new
          remove_method :old_new
        end
      end
    end
  end
end
