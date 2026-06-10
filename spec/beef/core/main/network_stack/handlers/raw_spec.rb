#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::NetworkStack::Handlers::Raw do
  describe '#initialize' do
    it 'initializes with status, header, and body' do
      handler = described_class.new('200', { 'Content-Type' => 'text/html' }, '<html></html>')
      expect(handler.instance_variable_get(:@status)).to eq('200')
      expect(handler.instance_variable_get(:@header)).to eq({ 'Content-Type' => 'text/html' })
      expect(handler.instance_variable_get(:@body)).to eq('<html></html>')
    end

    it 'initializes with default empty header and nil body' do
      handler = described_class.new('404')
      expect(handler.instance_variable_get(:@status)).to eq('404')
      expect(handler.instance_variable_get(:@header)).to eq({})
      expect(handler.instance_variable_get(:@body)).to be_nil
    end
  end

  describe '#call' do
    it 'returns Rack::Response with correct status, header, and body' do
      handler = described_class.new('200', { 'Content-Type' => 'text/html' }, '<html></html>')
      response = handler.call({})

      expect(response).to be_a(Rack::Response)
      expect(response.status).to eq(200)
      expect(response.headers['Content-Type']).to eq('text/html')
      expect(response.body).to eq(['<html></html>'])
    end

    it 'handles different status codes' do
      handler = described_class.new('404', {}, 'Not Found')
      response = handler.call({})

      expect(response.status).to eq(404)
      expect(response.body).to eq(['Not Found'])
    end

    it 'handles nil body' do
      handler = described_class.new('204', {})
      response = handler.call({})

      expect(response.status).to eq(204)
      expect(response.body).to eq([])
    end
  end
end
