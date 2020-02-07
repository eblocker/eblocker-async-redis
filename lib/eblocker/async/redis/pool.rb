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
require 'redis'

module Eblocker::Async::Redis

  class Pool

    def initialize(redis_options, logger)
      @redis_options = redis_options
      @logger = logger
      @pool = []
    end

    def connection(&block)
      @pool << Redis.new(@redis_options) if @pool.empty?
      connection = @pool.pop
      @logger.debug("checked out #{connection} (#{@pool.length})")
      return connection if !block_given?
      begin
        result = block.call(connection)
        put(connection)
        return result
      rescue Redis::BaseConnectionError
        @logger.debug("dropping #{connection} due to exception")
        raise
      rescue StandardError
        put(connection)
        raise
      end
    end

    def put(connection)
      @pool << connection
      @logger.debug("checked in #{connection} (#{@pool.length})")
    end

  end

end