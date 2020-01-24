require 'test_helper'
require 'user'

class StudentsApiTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include TestHelpers::AuthHelper
  include TestHelpers::JsonHelper

  def app
    Rails.application
  end

  def test_get_students_with_authentication
    # Create admin
    #adminUser = FactoryBot.create(:user, :admin)

    # Create unit
    newUnit = FactoryBot.create(:unit)

    #Create campus
    #newCampus = FactoryBot.create(:campus)

  #  expectedStudents = newUnit.projects.all
 #   expectedStudents each do | data |
 #     puts(data)
  #  end
    # Create student
   # studentUser = FactoryBot.create(:user, :student)

    # Assign student to the unit
    #newUnit.enrol_student(studentUser, newCampus)

    # The get that we will be testing.
    get with_auth_token "/api/students/?unit_id=#{newUnit.id}", newUnit.main_convenor_user
    #assert_equal expectedStudents.count, last_response_body.count
    #response_keys = %w(first_name last_name student_id project_id)
    #last_response_body.each do | data |
      #pro = Project.find(data['project_id'])
      #assert_json_matches_model(data, pro, response_keys)
    #end
    assert_equal 200, last_response.status
  end

  def test_get_students_without_authentication
    # Create student user
    studentUser = FactoryBot.create(:user, :student)

    # Create unit
    newUnit = FactoryBot.create(:unit)

    #Create campus
    newCampus = FactoryBot.create(:campus)

    # Assign student to the unit
    newUnit.enrol_student(studentUser, newCampus)

    # The get that we will be testing.
    get with_auth_token "/api/students/?unit_id=#{newUnit.id}",studentUser
    assert_equal 403, last_response.status
  end

  def test_get_students_without_parameters
    # Create admin
    adminUser = FactoryBot.create(:user, :admin)

    # The get that we will be testing without parameters.
    get with_auth_token '/api/students/',adminUser
    assert_equal 400, last_response.status
  end
end
