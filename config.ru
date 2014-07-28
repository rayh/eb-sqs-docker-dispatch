require 'rack'
require 'json'
require 'docker'

Docker.url = ENV['DOCKER_HOST']||"/docker.sock"

app = lambda do |env|
  request = Rack::Request.new(env)
  data = JSON.parse(request.body.read)
  p data.inspect

  puts "Dispatch job for image #{data['Image']} using Cmd #{data['Cmd']}"

  container = Docker::Container.create(data)
  container.start

  [200, { 'Content-Type' => 'application/json' }, [JSON.dump(id:container.id)]]
end

run app
