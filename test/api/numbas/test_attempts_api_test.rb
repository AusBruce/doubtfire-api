# frozen_string_literal: true

require 'test_helper'
require 'grape'

class TestAttemptsApiTest < ActiveSupport::TestCase
  include TestHelpers::AuthHelper
  include TestHelpers::TestFileHelper

  def setup
    @base_url = "/savetests"
    @xtest_attempt = FactoryBot.create(:xtest_attempt)
  end

  # Authentication header helper
  def authenticated_header
    { "Authorization" => "YourAuthToken" }
  end

  def test_get_all_test_results
    FactoryBot.create_list(:xtest_attempt, 5)
    get @base_url, headers: authenticated_header
    assert_response :success
    assert_equal 5, JSON.parse(response.body)["data"].size
  end

  def test_get_latest_test_or_create
    get "#{@base_url}/latest", headers: authenticated_header
    assert_response :success
  end

  def test_get_latest_completed_test_when_completed_tests_exist
    FactoryBot.create(:xtest_attempt, completed: true)
    get "#{@base_url}/completed-latest", headers: authenticated_header
    assert_response :success
  end

  def test_get_latest_completed_test_when_no_completed_tests
    get "#{@base_url}/completed-latest", headers: authenticated_header
    assert_response :not_found
  end

  def test_get_specified_test_result
    get "#{@base_url}/#{@xtest_attempt.id}", headers: authenticated_header
    assert_response :success
    assert_equal @xtest_attempt.id, JSON.parse(response.body)["data"]["id"]
  end

  def test_create_new_test_result
    valid_params = {
      task_id: 1,
      name: "New Test",
      attempt_number: 1,
      pass_status: true,
      completed: false
    }
    assert_difference 'TestAttempt.count', 1 do
      post @base_url, params: valid_params, headers: authenticated_header
    end
    assert_response :created
  end

  def test_update_test_result
    valid_update_params = { name: "Updated Test Name" }
    put "#{@base_url}/#{@xtest_attempt.id}", params: valid_update_params, headers: authenticated_header
    assert_response :success
    assert_equal "Updated Test Name", @xtest_attempt.reload.name
  end

  def test_delete_test_result
    delete "#{@base_url}/#{@xtest_attempt.id}", headers: authenticated_header
    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) { @xtest_attempt.reload }
  end

  def test_update_exam_data_for_test_result
    valid_exam_data = { exam_data: { question1: "answer", question2: "answer2" }.to_json }
    put "#{@base_url}/#{@xtest_attempt.id}/exam_data", params: valid_exam_data, headers: authenticated_header
    assert_response :success
    assert_equal valid_exam_data[:exam_data], @xtest_attempt.reload.exam_data
  end
end
