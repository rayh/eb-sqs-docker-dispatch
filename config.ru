require 'rack'
require './lib/common.rb'

# Run the main dispatch processor
app = lambda do |env|
  begin
    request = Rack::Request.new(env)
    message = JSON.parse(request.body.read)

    container_ids = message.map do |data|
      publish_status :pulling, image:data['Image']

      dispatch_logger.info "Fetching image #{data['Image']}"
      image, tag = data['Image'].split(/:/, 2)
      tag = 'latest' if tag.nil?
      Docker::Image.create('fromImage' => image, 'tag' => tag)


      publish_status :starting, {args:data}
      dispatch_logger.info "Dispatch job for image #{data['Image']} using Cmd #{data['Cmd']}"
      container = Docker::Container.create(data)
      container.start

      publish_status :started, {args:data, container_id:container.id}

      container.id
    end

    [200, { 'Content-Type' => 'application/json' }, [JSON.dump(ids:container_ids)]]
  rescue => e
    notify_error "Error dispatching job", e
    raise e
  end

end

publish_status :worker_start
begin
  run app
ensure
  publish_status :worker_stop
end
