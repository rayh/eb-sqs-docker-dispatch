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
    message = JSON.parse(request.body.read)

    container_ids = message.map do |data|
      dispatch_logger.info "Fetching image #{data['Image']}"
      Docker::Image.create('fromImage' => data['Image'])


      dispatch_logger.info "Dispatch job for image #{data['Image']} using Cmd #{data['Cmd']}"
      container = Docker::Container.create(data)
      container.start

      container.id
    end

    [200, { 'Content-Type' => 'application/json' }, [JSON.dump(ids:container_ids)]]
  rescue => e
    dispatch_logger.error "Got error #{e}"
    raise e
  end

end

run app
