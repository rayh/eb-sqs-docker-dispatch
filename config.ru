require 'rack'
require 'json'
require 'docker'
require 'logger'

Docker.url = "unix:///docker.sock"
Docker.logger = Logger.new('log/docker.log')

dispatch_logger = Logger.new('log/dispatch.log')

app = lambda do |env|
  begin
    request = Rack::Request.new(env)
    data = JSON.parse(request.body.read)

    dispatch_logger.info "Fetching image #{data['Image']}"
    Docker::Image.create('fromImage' => data['Image'])


    dispatch_logger.info "Dispatch job for image #{data['Image']} using Cmd #{data['Cmd']}"
    container = Docker::Container.create(data)
    container.start
  rescue => e
    dispatch_logger.error "Got error #{e}"
    raise e
  end

  [200, { 'Content-Type' => 'application/json' }, [JSON.dump(id:container.id)]]
end

run app
