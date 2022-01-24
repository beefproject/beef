class CreateHttp < ActiveRecord::Migration[6.0]
  def change
    create_table :https do |t|
      t.text :hooked_browser_id
      # The http request to perform. In clear text.
      t.text :request
      # Boolean value as string to say whether cross-domain requests are allowed
      t.boolean :allow_cross_domain, default: true
      # The http response body received. In clear text.
      t.text :response_data
      # The http response code. Useful to handle cases like 404, 500, 302, ...
      t.integer :response_status_code
      # The http response code. Human-readable code: success, error, ecc..
      t.text :response_status_text
      # The port status. closed, open or not http
      t.text :response_port_status
      # The XHR Http response raw headers
      t.text :response_headers
      # The http response method. GET or POST.
      t.text :method
      # The content length for the request.
      t.text :content_length, default: 0
      # The request protocol/scheme (http/https)
      t.text :proto
      # The domain on which perform the request.
      t.text :domain
      # The port on which perform the request.
      t.text :port
      # Boolean value to say if the request was cross-domain
      t.text :has_ran, default: 'waiting'
      # The path of the request.
      # Example: /secret.html
      t.text :path
      # The date at which the http response has been saved.
      t.datetime :response_date
      # The date at which the http request has been saved.
      t.datetime :request_date
    end
  end
end
