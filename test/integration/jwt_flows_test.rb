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
    post '/user_token', params: params.to_json, headers: { 'Content-Type' => 'application/json' }
    assert_response :success
  end

  test 'can list users with token' do
    params = { auth: { name: 'admin', password: 'admin' } }
    post '/user_token', params: params.to_json, headers: { 'Content-Type' => 'application/json' }
    assert_response :success

    token = JSON.parse(@response.body)
    get '/users', headers: { 'Authorization' => "Bearer #{token['jwt']}" }
    assert_response :success
  end
end
