class Rack::Attack
  limit = ENV['SOMBRA_RATE_LIMIT_REQUESTS'] || 300
  period = ENV['SOMBRA_RATE_LIMIT_PERIOD_IN_S'] || 10

  throttle('req/ip', :limit => limit.to_i, :period => period.to_i.seconds) do |req|
    req.ip
  end

  Rack::Attack.throttled_response = lambda do |env|
    now = Time.now.utc
    match_data = env['rack.attack.match_data']

    headers = {
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
    }

    [ 429, headers, ["Throttled"]]
  end
end
