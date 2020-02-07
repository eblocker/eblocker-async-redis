#
# Copyright 2020 eBlocker Open Source UG (haftungsbeschraenkt)
#
# Licensed under the EUPL, Version 1.2 or - as soon they will be
# approved by the European Commission - subsequent versions of the EUPL
# (the "License"); You may not use this work except in compliance with
# the License. You may obtain a copy of the License at:
#
#   https://joinup.ec.europa.eu/page/eupl-text-11-12
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#
require 'redis/connection/registry'
require 'redis/connection/command_helper'
require 'redis/errors'

require 'async/io/endpoint'

module Eblocker::Async::Redis

  module Connection

      class AsyncIo
        include Redis::Connection::CommandHelper

        CRLF = "\r\n".freeze

        MINUS = "-".freeze
        PLUS = "+".freeze
        COLON = ":".freeze
        DOLLAR = "$".freeze
        ASTERISK = "*".freeze

        def self.connect(config)
          socket = ::Async::IO::Endpoint.tcp(config[:host], config[:port]).connect

          instance = new(socket)
          instance
        end

        def initialize(socket)
          @socket = socket
          @buffer = ""
        end

        def connected?
          !!@socket
        end

        def disconnect
          @socket.close
        rescue
        ensure
          @socket = nil
        end

        def timeout=(timeout)
        end

        def write_timeout=(timeout)
        end

        def write(command)
          @socket.write(build_command(command))
        end

        def readSocket(n)
          result = @buffer.slice!(0, n)
          while result.length < n
            result << socket_read(n - result.length)
          end
          result
        end

        def read
          index = @buffer.index("\r\n")
          while !index
            @buffer << socket_read(1024)
            index = @buffer.index("\r\n")
          end
          line = @buffer.slice!(0, index + 2).rstrip
          reply_type = line.slice!(0, 1)
          format_reply(reply_type, line)
        end

        def socket_read(n)
          buffer = @socket.read(n)
          raise Redis::ConnectionError unless buffer
          return buffer
        end

        def format_reply(reply_type, line)
          case reply_type
          when MINUS then
            format_error_reply(line)
          when PLUS then
            format_status_reply(line)
          when COLON then
            format_integer_reply(line)
          when DOLLAR then
            format_bulk_reply(line)
          when ASTERISK then
            format_multi_bulk_reply(line)
          else
            raise ProtocolError.new(reply_type)
          end
        end

        def format_error_reply(line)
          CommandError.new(line.strip)
        end

        def format_status_reply(line)
          line.strip
        end

        def format_integer_reply(line)
          line.to_i
        end

        def format_bulk_reply(line)
          bulklen = line.to_i
          return if bulklen == -1
          reply = encode(readSocket(bulklen))
          readSocket(2) # Discard CRLF.
          reply
        end

        def format_multi_bulk_reply(line)
          n = line.to_i
          return if n == -1

          Array.new(n) {read}
        end
      end

  end

  Redis::Connection.drivers << Connection::AsyncIo

end
