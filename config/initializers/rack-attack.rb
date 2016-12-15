class Rack::Attack
  throttle('user_token/ip', :limit => 10, :period => 10.seconds) do |req|
    if req.path == '/user_token' && req.post?
      req.ip
    end
  end

  Rack::Attack.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']

    headers = {
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
    }

    [ 429, headers, ["Throttled\n"]]
  end
end
