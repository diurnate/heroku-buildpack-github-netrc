require 'json'

def server_token? token
  return token.start_with? "ghs_"
end

def valid_login? token
  # ghs are server-to-server tokens so cannot login normally.
  if server_token? token
    return true
  end
  login(token) != "error"
end

def login token
  @login ||= github_user_login(token)
end

def github_user_login token
  json = `curl -H "Authorization: Bearer #{token}" -s https://api.github.com/user` rescue "{}"
  user = JSON.parse json rescue {}
  user["login"] || "error"
end

def github_user_orgs token
  json = `curl -H "Authorization: Bearer #{token}" -s https://api.github.com/user/orgs` rescue "[]"
  orgs = JSON.parse json rescue []
  orgs.map {|o| o["login"].downcase }.sort
end

def user_block token
  if server_token? token
    <<-SERVER
        GitHub User: server-to-server token
    SERVER
  else
    <<-USER
        GitHub User:   #{login(token)}
        Organizations: #{github_user_orgs(token).join(", ")}
    USER
  end
end
