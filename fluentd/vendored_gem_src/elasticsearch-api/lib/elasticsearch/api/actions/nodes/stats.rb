# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

module Elasticsearch
  module API
    module Nodes
      module Actions
        # Returns statistical information about nodes in the cluster.
        #
        # @option arguments [List] :node_id A comma-separated list of node IDs or names to limit the returned information; use `_local` to return information from the node you're connecting to, leave empty to get information from all nodes
        # @option arguments [List] :metric Limit the information returned to the specified metrics
        #   (options: _all,breaker,fs,http,indices,jvm,os,process,thread_pool,transport,discovery)

        # @option arguments [List] :index_metric Limit the information returned for `indices` metric to the specific index metrics. Isn't used if `indices` (or `all`) metric isn't specified.
        #   (options: _all,completion,docs,fielddata,query_cache,flush,get,indexing,merge,request_cache,refresh,search,segments,store,warmer,suggest)

        # @option arguments [List] :completion_fields A comma-separated list of fields for `fielddata` and `suggest` index metric (supports wildcards)
        # @option arguments [List] :fielddata_fields A comma-separated list of fields for `fielddata` index metric (supports wildcards)
        # @option arguments [List] :fields A comma-separated list of fields for `fielddata` and `completion` index metric (supports wildcards)
        # @option arguments [Boolean] :groups A comma-separated list of search groups for `search` index metric
        # @option arguments [String] :level Return indices stats aggregated at index, node or shard level
        #   (options: indices,node,shards)

        # @option arguments [List] :types A comma-separated list of document types for the `indexing` index metric
        # @option arguments [Time] :timeout Explicit operation timeout
        # @option arguments [Boolean] :include_segment_file_sizes Whether to report the aggregated disk usage of each one of the Lucene index files (only applies if segment stats are requested)

        #
        # @see https://www.elastic.co/guide/en/elasticsearch/reference/7.5/cluster-nodes-stats.html
        #
        def stats(arguments = {})
          arguments = arguments.clone

          _node_id = arguments.delete(:node_id)

          _metric = arguments.delete(:metric)

          _index_metric = arguments.delete(:index_metric)

          method = Elasticsearch::API::HTTP_GET
          path   = if _node_id && _metric && _index_metric
                     "_nodes/#{Utils.__listify(_node_id)}/stats/#{Utils.__listify(_metric)}/#{Utils.__listify(_index_metric)}"
                   elsif _metric && _index_metric
                     "_nodes/stats/#{Utils.__listify(_metric)}/#{Utils.__listify(_index_metric)}"
                   elsif _node_id && _metric
                     "_nodes/#{Utils.__listify(_node_id)}/stats/#{Utils.__listify(_metric)}"
                   elsif _node_id
                     "_nodes/#{Utils.__listify(_node_id)}/stats"
                   elsif _metric
                     "_nodes/stats/#{Utils.__listify(_metric)}"
                   else
                     "_nodes/stats"
end
          params = Utils.__validate_and_extract_params arguments, ParamsRegistry.get(__method__)

          body = nil
          perform_request(method, path, params, body).body
        end

        # Register this action with its valid params when the module is loaded.
        #
        # @since 6.2.0
        ParamsRegistry.register(:stats, [
          :completion_fields,
          :fielddata_fields,
          :fields,
          :groups,
          :level,
          :types,
          :timeout,
          :include_segment_file_sizes
        ].freeze)
end
      end
  end
end