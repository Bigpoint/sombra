# encoding: UTF-8
# frozen_string_literal: true

require 'test_helper'

class JwtFlowsTest < ActionDispatch::IntegrationTest
  test 'can access public key' do
    get '/'
    assert_response :success
    content = JSON.parse(@response.body)
    refute_empty content['Pubkey']
  end

  test 'can generate jwt' do
    params = { auth: { name: 'admin', password: 'admin' } }
    post  '/user_token',
          params: params.to_json,
          headers: { 'Content-Type' => 'application/json' }

    assert_response :success
  end

  test 'can list users with token' do
    # auth
    params = { auth: { name: 'admin', password: 'admin' } }
    post  '/user_token',
          params: params.to_json,
          headers: { 'Content-Type' => 'application/json' }

    assert_response :success
    token = JSON.parse(@response.body)

    get '/users', headers: { 'Authorization' => "Bearer #{token['jwt']}" }
    assert_response :success
  end

  test 'can create&update&delete user with token' do
    # auth
    params = { auth: { name: 'admin', password: 'admin' } }
    post  '/user_token',
          params: params.to_json,
          headers: { 'Content-Type' => 'application/json' }

    assert_response :success
    token = JSON.parse(@response.body)

    # create
    params = { user: { name: 'app', password: 'application', role: 'application' } }
    post  '/users',
          params: params.to_json,
          headers: { 'Authorization' => "Bearer #{token['jwt']}", 'Content-Type' => 'application/json' }

    assert_response :success
    user_id = JSON.parse(@response.body)['_id']['$oid']

    # update
    params = { user: { name: 'apprenamed', password: 'newpassword', role: 'janitor' } }
    put "/users/#{user_id}",
        params: params.to_json,
        headers: { 'Authorization' => "Bearer #{token['jwt']}", 'Content-Type' => 'application/json' }

    assert_response :success

    # delete
    delete  "/users/#{user_id}",
            headers: { 'Authorization' => "Bearer #{token['jwt']}", 'Content-Type' => 'application/json' }

    assert_response :success
  end
end
