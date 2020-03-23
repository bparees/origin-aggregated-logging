# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

module Elasticsearch
  module API
    module Actions
      # Removes a document from the index.
      #
      # @option arguments [String] :id The document ID
      # @option arguments [String] :index The name of the index
      # @option arguments [String] :type The type of the document   *Deprecated*
      # @option arguments [String] :wait_for_active_shards Sets the number of shard copies that must be active before proceeding with the delete operation. Defaults to 1, meaning the primary shard only. Set to `all` for all shard copies, otherwise set to any non-negative value less than or equal to the total number of copies for the shard (number of replicas + 1)
      # @option arguments [String] :refresh If `true` then refresh the affected shards to make this operation visible to search, if `wait_for` then wait for a refresh to make this operation visible to search, if `false` (the default) then do nothing with refreshes.
      #   (options: true,false,wait_for)

      # @option arguments [String] :routing Specific routing value
      # @option arguments [Time] :timeout Explicit operation timeout
      # @option arguments [Number] :if_seq_no only perform the delete operation if the last operation that has changed the document has the specified sequence number
      # @option arguments [Number] :if_primary_term only perform the delete operation if the last operation that has changed the document has the specified primary term
      # @option arguments [Number] :version Explicit version number for concurrency control
      # @option arguments [String] :version_type Specific version type
      #   (options: internal,external,external_gte,force)

      #
      # *Deprecation notice*:
      # Specifying types in urls has been deprecated
      # Deprecated since version 7.0.0
      #
      #
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/7.5/docs-delete.html
      #
      def delete(arguments = {})
        raise ArgumentError, "Required argument 'index' missing" unless arguments[:index]
        raise ArgumentError, "Required argument 'id' missing" unless arguments[:id]

        arguments = arguments.clone

        _id = arguments.delete(:id)

        _index = arguments.delete(:index)

        _type = arguments.delete(:type)

        method = Elasticsearch::API::HTTP_DELETE
        path   = if _index && _type && _id
                   "#{Utils.__listify(_index)}/#{Utils.__listify(_type)}/#{Utils.__listify(_id)}"
                 else
                   "#{Utils.__listify(_index)}/_doc/#{Utils.__listify(_id)}"
  end
        params = Utils.__validate_and_extract_params arguments, ParamsRegistry.get(__method__)

        body = nil
        if Array(arguments[:ignore]).include?(404)
          Utils.__rescue_from_not_found { perform_request(method, path, params, body).body }
        else
          perform_request(method, path, params, body).body
        end
      end

      # Register this action with its valid params when the module is loaded.
      #
      # @since 6.2.0
      ParamsRegistry.register(:delete, [
        :wait_for_active_shards,
        :refresh,
        :routing,
        :timeout,
        :if_seq_no,
        :if_primary_term,
        :version,
        :version_type
      ].freeze)
    end
    end
end