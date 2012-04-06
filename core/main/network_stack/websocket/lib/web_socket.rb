# Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# Lincense: New BSD Lincense
# Reference: http://tools.ietf.org/html/draft-hixie-thewebsocketprotocol-75
# Reference: http://tools.ietf.org/html/draft-hixie-thewebsocketprotocol-76
# Reference: http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-07
# Reference: http://tools.ietf.org/html/draft-ietf-hybi-thewebsocketprotocol-10

require "base64"
require "socket"
require "uri"
require "digest/md5"
require "digest/sha1"
require "openssl"
require "stringio"


class WebSocket

    class << self

        attr_accessor(:debug)

    end

    class Error < RuntimeError

    end
    
    WEB_SOCKET_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
    OPCODE_CONTINUATION = 0x00
    OPCODE_TEXT = 0x01
    OPCODE_BINARY = 0x02
    OPCODE_CLOSE = 0x08
    OPCODE_PING = 0x09
    OPCODE_PONG = 0x0a

    def initialize(arg, params = {})
      if params[:server] # server

        @server = params[:server]
        @socket = arg
        line = gets().chomp()
        if !(line =~ /\AGET (\S+) HTTP\/1.1\z/n)
          raise(WebSocket::Error, "invalid request: #{line}")
        end
        @path = $1
        read_header()
        if @header["sec-websocket-version"]
          @web_socket_version = @header["sec-websocket-version"]
          @key3 = nil
        elsif @header["sec-websocket-key1"] && @header["sec-websocket-key2"]
          @web_socket_version = "hixie-76"
          @key3 = read(8)
        else
          @web_socket_version = "hixie-75"
          @key3 = nil
        end
        if !@server.accepted_origin?(self.origin)
          raise(WebSocket::Error,
            ("Unaccepted origin: %s (server.accepted_domains = %p)\n\n" +
              "To accept this origin, write e.g. \n" +
              "  WebSocketServer.new(..., :accepted_domains => [%p]), or\n" +
              "  WebSocketServer.new(..., :accepted_domains => [\"*\"])\n") %
            [self.origin, @server.accepted_domains, @server.origin_to_domain(self.origin)])
        end
        @handshaked = false

      else # client
        
        @web_socket_version = "hixie-76"
        uri = arg.is_a?(String) ? URI.parse(arg) : arg

        if uri.scheme == "ws"
          default_port = 80
        elsif uri.scheme = "wss"
          default_port = 443
        else
          raise(WebSocket::Error, "unsupported scheme: #{uri.scheme}")
        end

        @path = (uri.path.empty? ? "/" : uri.path) + (uri.query ? "?" + uri.query : "")
        host = uri.host + ((!uri.port || uri.port == default_port) ? "" : ":#{uri.port}")
        origin = params[:origin] || "http://#{uri.host}"
        key1 = generate_key()
        key2 = generate_key()
        key3 = generate_key3()

        socket = TCPSocket.new(uri.host, uri.port || default_port)

        if uri.scheme == "ws"
          @socket = socket
        else
          @socket = ssl_handshake(socket)
        end

        write(
          "GET #{@path} HTTP/1.1\r\n" +
          "Upgrade: WebSocket\r\n" +
          "Connection: Upgrade\r\n" +
          "Host: #{host}\r\n" +
          "Origin: #{origin}\r\n" +
          "Sec-WebSocket-Key1: #{key1}\r\n" +
          "Sec-WebSocket-Key2: #{key2}\r\n" +
          "\r\n" +
          "#{key3}")
        flush()

        line = gets().chomp()
        raise(WebSocket::Error, "bad response: #{line}") if !(line =~ /\AHTTP\/1.1 101 /n)
        read_header()
        if (@header["sec-websocket-origin"] || "").downcase() != origin.downcase()
          raise(WebSocket::Error,
            "origin doesn't match: '#{@header["sec-websocket-origin"]}' != '#{origin}'")
        end
        reply_digest = read(16)
        expected_digest = hixie_76_security_digest(key1, key2, key3)
        if reply_digest != expected_digest
          raise(WebSocket::Error,
            "security digest doesn't match: %p != %p" % [reply_digest, expected_digest])
        end
        @handshaked = true

      end
      @received = []
      @buffer = ""
      @closing_started = false
    end

    attr_reader(:server, :header, :path)

    def handshake(status = nil, header = {})
      if @handshaked
        raise(WebSocket::Error, "handshake has already been done")
      end
      status ||= "101 Switching Protocols"
      def_header = {}
      case @web_socket_version
        when "hixie-75"
          def_header["WebSocket-Origin"] = self.origin
          def_header["WebSocket-Location"] = self.location
          extra_bytes = ""
        when "hixie-76"
          def_header["Sec-WebSocket-Origin"] = self.origin
          def_header["Sec-WebSocket-Location"] = self.location
          extra_bytes = hixie_76_security_digest(
            @header["Sec-WebSocket-Key1"], @header["Sec-WebSocket-Key2"], @key3)
        else
          def_header["Sec-WebSocket-Accept"] = security_digest(@header["sec-websocket-key"])
          extra_bytes = ""
      end
      header = def_header.merge(header)
      header_str = header.map(){ |k, v| "#{k}: #{v}\r\n" }.join("")
      # Note that Upgrade and Connection must appear in this order.
      write(
        "HTTP/1.1 #{status}\r\n" +
        "Upgrade: websocket\r\n" +
        "Connection: Upgrade\r\n" +
        "#{header_str}\r\n#{extra_bytes}")
      flush()
      @handshaked = true
    end

    def send(data)
      if !@handshaked
        raise(WebSocket::Error, "call WebSocket\#handshake first")
      end
      case @web_socket_version
        when "hixie-75", "hixie-76"
          data = force_encoding(data.dup(), "ASCII-8BIT")
          write("\x00#{data}\xff")
          flush()
        else
          send_frame(OPCODE_TEXT, data, !@server)
      end
    end
    
    def receive()
      if !@handshaked
        raise(WebSocket::Error, "call WebSocket\#handshake first")
      end
      case @web_socket_version
        
        when "hixie-75", "hixie-76"
          packet = gets("\xff")
          return nil if !packet
          if packet =~ /\A\x00(.*)\xff\z/nm
            return force_encoding($1, "UTF-8")
          elsif packet == "\xff" && read(1) == "\x00" # closing
            close(1005, "", :peer)
            return nil
          else
            raise(WebSocket::Error, "input must be either '\\x00...\\xff' or '\\xff\\x00'")
          end
        
        else
          begin
            bytes = read(2).unpack("C*")
            fin = (bytes[0] & 0x80) != 0
            opcode = bytes[0] & 0x0f
            mask = (bytes[1] & 0x80) != 0
            plength = bytes[1] & 0x7f
            if plength == 126
              bytes = read(2)
              plength = bytes.unpack("n")[0]
            elsif plength == 127
              bytes = read(8)
              (high, low) = bytes.unpack("NN")
              plength = high * (2 ** 32) + low
            end
            if @server && !mask
              # Masking is required.
              @socket.close()
              raise(WebSocket::Error, "received unmasked data")
            end
            mask_key = mask ? read(4).unpack("C*") : nil
            payload = read(plength)
            payload = apply_mask(payload, mask_key) if mask
            case opcode
              when OPCODE_TEXT
                return force_encoding(payload, "UTF-8")
              when OPCODE_BINARY
                raise(WebSocket::Error, "received binary data, which is not supported")
              when OPCODE_CLOSE
                close(1005, "", :peer)
                return nil
              when OPCODE_PING
                raise(WebSocket::Error, "received ping, which is not supported")
              when OPCODE_PONG
              else
                raise(WebSocket::Error, "received unknown opcode: %d" % opcode)
            end
          rescue EOFError
            return nil
          end
        
      end
    end
    
    def tcp_socket
      return @socket
    end

    def host
      return @header["host"]
    end

    def origin
      case @web_socket_version
        when "7", "8"
          name = "sec-websocket-origin"
        else
          name = "origin"
      end
      if @header[name]
        return @header[name]
      else
        raise(WebSocket::Error, "%s header is missing" % name)
      end
    end

    def location
      return "ws://#{self.host}#{@path}"
    end
    
    # Does closing handshake.
    def close(code = 1005, reason = "", origin = :self)
      if !@closing_started
        case @web_socket_version
          when "hixie-75", "hixie-76"
            write("\xff\x00")
          else
            if code == 1005
              payload = ""
            else
              payload = [code].pack("n") + force_encoding(reason.dup(), "ASCII-8BIT")
            end
            send_frame(OPCODE_CLOSE, payload, false)
        end
      end
      @socket.close() if origin == :peer
      @closing_started = true
    end
    
    def close_socket()
      @socket.close()
    end

  private

    NOISE_CHARS = ("\x21".."\x2f").to_a() + ("\x3a".."\x7e").to_a()

    def read_header()
      @header = {}
      while line = gets()
        line = line.chomp()
        break if line.empty?
        if !(line =~ /\A(\S+): (.*)\z/n)
          raise(WebSocket::Error, "invalid request: #{line}")
        end
        @header[$1] = $2
        @header[$1.downcase()] = $2
      end
      if !@header["upgrade"]
        raise(WebSocket::Error, "Upgrade header is missing")
      end
      if !(@header["upgrade"] =~ /\AWebSocket\z/i)
        raise(WebSocket::Error, "invalid Upgrade: " + @header["upgrade"])
      end
      if !@header["connection"]
        raise(WebSocket::Error, "Connection header is missing")
      end
      if @header["connection"].split(/,/).grep(/\A\s*Upgrade\s*\z/i).empty?
        raise(WebSocket::Error, "invalid Connection: " + @header["connection"])
      end
    end

    def send_frame(opcode, payload, mask)
      payload = force_encoding(payload.dup(), "ASCII-8BIT")
      # Setting StringIO's encoding to ASCII-8BIT.
      buffer = StringIO.new(force_encoding("", "ASCII-8BIT"))
      write_byte(buffer, 0x80 | opcode)
      masked_byte = mask ? 0x80 : 0x00
      if payload.bytesize <= 125
        write_byte(buffer, masked_byte | payload.bytesize)
      elsif payload.bytesize < 2 ** 16
        write_byte(buffer, masked_byte | 126)
        buffer.write([payload.bytesize].pack("n"))
      else
        write_byte(buffer, masked_byte | 127)
        buffer.write([payload.bytesize / (2 ** 32), payload.bytesize % (2 ** 32)].pack("NN"))
      end
      if mask
        mask_key = Array.new(4){ rand(256) }
        buffer.write(mask_key.pack("C*"))
        payload = apply_mask(payload, mask_key)
      end
      buffer.write(payload)
      write(buffer.string)
    end

    def gets(rs = $/)
      line = @socket.gets(rs)
      $stderr.printf("recv> %p\n", line) if WebSocket.debug
      return line
    end

    def read(num_bytes)
      str = @socket.read(num_bytes)
      $stderr.printf("recv> %p\n", str) if WebSocket.debug
      if str && str.bytesize == num_bytes
        return str
      else
        raise(EOFError)
      end
    end

    def write(data)
      if WebSocket.debug
        data.scan(/\G(.*?(\n|\z))/n) do
          $stderr.printf("send> %p\n", $&) if !$&.empty?
        end
      end
      @socket.write(data)
    end

    def flush()
      @socket.flush()
    end
    
    def write_byte(buffer, byte)
      buffer.write([byte].pack("C"))
    end
    
    def security_digest(key)
      return Base64.encode64(Digest::SHA1.digest(key + WEB_SOCKET_GUID)).gsub(/\n/, "")
    end

    def hixie_76_security_digest(key1, key2, key3)
      bytes1 = websocket_key_to_bytes(key1)
      bytes2 = websocket_key_to_bytes(key2)
      return Digest::MD5.digest(bytes1 + bytes2 + key3)
    end

    def apply_mask(payload, mask_key)
      orig_bytes = payload.unpack("C*")
      new_bytes = []
      orig_bytes.each_with_index() do |b, i|
        new_bytes.push(b ^ mask_key[i % 4])
      end
      return new_bytes.pack("C*")
    end

    def generate_key()
      spaces = 1 + rand(12)
      max = 0xffffffff / spaces
      number = rand(max + 1)
      key = (number * spaces).to_s()
      (1 + rand(12)).times() do
        char = NOISE_CHARS[rand(NOISE_CHARS.size)]
        pos = rand(key.size + 1)
        key[pos...pos] = char
      end
      spaces.times() do
        pos = 1 + rand(key.size - 1)
        key[pos...pos] = " "
      end
      return key
    end

    def generate_key3()
      return [rand(0x100000000)].pack("N") + [rand(0x100000000)].pack("N")
    end

    def websocket_key_to_bytes(key)
      num = key.gsub(/[^\d]/n, "").to_i() / key.scan(/ /).size
      return [num].pack("N")
    end

    def force_encoding(str, encoding)
      if str.respond_to?(:force_encoding)
        return str.force_encoding(encoding)
      else
        return str
      end
    end

    def ssl_handshake(socket)
      ssl_context = OpenSSL::SSL::SSLContext.new()
      ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
      ssl_socket.sync_close = true
      ssl_socket.connect()
      return ssl_socket
    end

end


class WebSocketServer

    def initialize(params_or_uri, params = nil)
      if params
        uri = params_or_uri.is_a?(String) ? URI.parse(params_or_uri) : params_or_uri
        params[:port] ||= uri.port
        params[:accepted_domains] ||= [uri.host]
      else
        params = params_or_uri
      end
      @port = params[:port] || 80
      @accepted_domains = params[:accepted_domains]
      if !@accepted_domains
        raise(ArgumentError, "params[:accepted_domains] is required")
      end
      if params[:host]
        @tcp_server = TCPServer.open(params[:host], @port)
      else
        @tcp_server = TCPServer.open(@port)
      end
    end

    attr_reader(:tcp_server, :port, :accepted_domains)

    def run(&block)
      while true
        Thread.start(accept()) do |s|
          begin
            ws = create_web_socket(s)
            yield(ws) if ws
          rescue => ex
            print_backtrace(ex)
          ensure
            begin
              ws.close_socket() if ws
            rescue
            end
          end
        end
      end
    end

    def accept()
      return @tcp_server.accept()
    end

    def accepted_origin?(origin)
      domain = origin_to_domain(origin)
      return @accepted_domains.any?(){ |d| File.fnmatch(d, domain) }
    end

    def origin_to_domain(origin)
      if origin == "null" || origin == "file://"  # local file
        return "null"
      else
        return URI.parse(origin).host
      end
    end

    def create_web_socket(socket)
      ch = socket.getc()
      if ch == ?<
        # This is Flash socket policy file request, not an actual Web Socket connection.
        send_flash_socket_policy_file(socket)
        return nil
      else
        socket.ungetc(ch)
        return WebSocket.new(socket, :server => self)
      end
    end

  private

    def print_backtrace(ex)
      $stderr.printf("%s: %s (%p)\n", ex.backtrace[0], ex.message, ex.class)
      for s in ex.backtrace[1..-1]
        $stderr.printf("        %s\n", s)
      end
    end

    # Handles Flash socket policy file request sent when web-socket-js is used:
    # http://github.com/gimite/web-socket-js/tree/master
    def send_flash_socket_policy_file(socket)
      socket.puts('<?xml version="1.0"?>')
      socket.puts('<!DOCTYPE cross-domain-policy SYSTEM ' +
        '"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">')
      socket.puts('<cross-domain-policy>')
      for domain in @accepted_domains
        next if domain == "file://"
        socket.puts("<allow-access-from domain=\"#{domain}\" to-ports=\"#{@port}\"/>")
      end
      socket.puts('</cross-domain-policy>')
      socket.close()
    end

end


if __FILE__ == $0
  Thread.abort_on_exception = true

  if ARGV[0] == "server" && ARGV.size == 3

    server = WebSocketServer.new(
      :accepted_domains => [ARGV[1]],
      :port => ARGV[2].to_i())
    puts("Server is running at port %d" % server.port)
    server.run() do |ws|
      puts("Connection accepted")
      puts("Path: #{ws.path}, Origin: #{ws.origin}")
      if ws.path == "/"
        ws.handshake()
        while data = ws.receive()
          printf("Received: %p\n", data)
          ws.send(data)
          printf("Sent: %p\n", data)
        end
      elsif ws.path  == "/badjs"
        printf("Received: %s\n", ws.path)
        #modules code here inject

      else
        ws.handshake("404 Not Found")
      end
      puts("Connection closed")
    end

  elsif ARGV[0] == "client" && ARGV.size == 2

    client = WebSocket.new(ARGV[1])
    puts("Connected")
    Thread.new() do
      while data = client.receive()
        printf("Received: %p\n", data)
      end
    end
    $stdin.each_line() do |line|
      data = line.chomp()
      client.send(data)
      printf("Sent: %p\n", data)
    end

  else

    $stderr.puts("Usage:")
    $stderr.puts("  ruby web_socket.rb server ACCEPTED_DOMAIN PORT")
    $stderr.puts("  ruby web_socket.rb client ws://HOST:PORT/")
    exit(1)

  end
end
