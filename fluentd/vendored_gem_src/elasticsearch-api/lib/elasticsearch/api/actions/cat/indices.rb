# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

module Elasticsearch
  module API
    module Cat
      module Actions
        # Returns information about indices: number of primaries and replicas, document counts, disk size, ...
        #
        # @option arguments [List] :index A comma-separated list of index names to limit the returned information
        # @option arguments [String] :format a short version of the Accept header, e.g. json, yaml
        # @option arguments [String] :bytes The unit in which to display byte values
        #   (options: b,k,m,g)

        # @option arguments [Boolean] :local Return local information, do not retrieve the state from master node (default: false)
        # @option arguments [Time] :master_timeout Explicit operation timeout for connection to master node
        # @option arguments [List] :h Comma-separated list of column names to display
        # @option arguments [String] :health A health status ("green", "yellow", or "red" to filter only indices matching the specified health status
        #   (options: green,yellow,red)

        # @option arguments [Boolean] :help Return help information
        # @option arguments [Boolean] :pri Set to true to return stats only for primary shards
        # @option arguments [List] :s Comma-separated list of column names or column aliases to sort by
        # @option arguments [String] :time The unit in which to display time values
        #   (options: d (Days),h (Hours),m (Minutes),s (Seconds),ms (Milliseconds),micros (Microseconds),nanos (Nanoseconds))

        # @option arguments [Boolean] :v Verbose mode. Display column headers
        # @option arguments [Boolean] :include_unloaded_segments If set to true segment stats will include stats for segments that are not currently loaded into memory

        #
        # @see https://www.elastic.co/guide/en/elasticsearch/reference/7.5/cat-indices.html
        #
        def indices(arguments = {})
          arguments = arguments.clone

          _index = arguments.delete(:index)

          method = Elasticsearch::API::HTTP_GET
          path   = if _index
                     "_cat/indices/#{Utils.__listify(_index)}"
                   else
                     "_cat/indices"
end
          params = Utils.__validate_and_extract_params arguments, ParamsRegistry.get(__method__)
          params[:h] = Utils.__listify(params[:h]) if params[:h]

          body = nil
          perform_request(method, path, params, body).body
        end

        # Register this action with its valid params when the module is loaded.
        #
        # @since 6.2.0
        ParamsRegistry.register(:indices, [
          :format,
          :bytes,
          :local,
          :master_timeout,
          :h,
          :health,
          :help,
          :pri,
          :s,
          :time,
          :v,
          :include_unloaded_segments
        ].freeze)
end
      end
  end
end
