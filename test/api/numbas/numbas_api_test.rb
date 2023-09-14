# frozen_string_literal: true

require 'test_helper'

class NumbasApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include TestHelpers::AuthHelper
  include TestHelpers::TestFileHelper
  include TestHelpers::JsonHelper

  def app
    NumbasApi
  end

  setup do
    @unit_code = "CSC101"
    @task_definition_id = 1
    @zip_file_path = FileHelper.get_numbas_test_path(@unit_code, @task_definition_id, 'numbas_test.zip')

    @unit = FactoryBot.create(:unit, code: @unit_code)
    @task_definition = FactoryBot.create(:task_definition, unit: @unit, id: @task_definition_id)
  end

  def test_authentication
    get '/numbas_api/index.html'
    assert_equal 401, last_response.status, last_response_body
  end

  def test_index_route
    add_auth_header_for_some_authenticated_user
    get "/numbas_api/index.html", { unit_code: @unit_code, task_definition_id: @task_definition_id }

    assert_equal 200, last_response.status
    assert_equal "Welcome to Numbas API", last_response_body
  end

  def test_file_route
    add_auth_header_for_some_authenticated_user
    test_file = "sample.txt"

    get "/numbas_api/#{test_file}", { unit_code: @unit_code, task_definition_id: @task_definition_id, format: 'txt' }
    assert_equal 200, last_response.status
    assert_includes last_response_body, "Sample content for sample.txt"
  end

  def test_file_not_found_in_zip
    add_auth_header_for_some_authenticated_user
    test_file = "non_existent_file"

    get "/numbas_api/#{test_file}", { unit_code: @unit_code, task_definition_id: @task_definition_id, format: 'txt' }
    assert_equal 404, last_response.status
    assert_equal "File not found", last_response_body
  end

  def test_upload_numbas_test
    add_auth_header_for_some_authenticated_user
    tempfile = Tempfile.new('test')
    tempfile.write("sample data")
    tempfile.rewind

    post "/numbas_api/uploadNumbasTest", { unit_code: @unit_code, task_definition_id: @task_definition_id, file: Rack::Test::UploadedFile.new(tempfile.path) }
    assert_equal 200, last_response.status
    assert_equal({ "success" => true, "message" => "File uploaded successfully" }, json_body)
  end

  def test_upload_numbas_test_without_file
    add_auth_header_for_some_authenticated_user

    post "/numbas_api/uploadNumbasTest", { unit_code: @unit_code, task_definition_id: @task_definition_id }
    assert_equal 400, last_response.status
    assert_equal({ "error" => "File upload is missing" }, json_body)
  end

  teardown do
    # Cleanup created files and database records
    FileUtils.rm_f(@zip_file_path)
    @task_definition.destroy!
    @unit.destroy!
  end
end
