require 'json-schema/attribute'
require 'json-schema/errors/schema_error'
require 'json-schema/util/uri'

module JSON
  class Schema
    class RefAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        uri,schema = get_referenced_uri_and_schema(current_schema.schema, current_schema, validator)

        if schema
          schema.validate(data, fragments, processor, options)
        elsif uri
          message = "The referenced schema '#{uri.to_s}' cannot be found"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        else
          message = "The property '#{build_fragment(fragments)}' was not a valid schema"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end

      def self.get_referenced_uri_and_schema(s, current_schema, validator)
        uri,schema = nil,nil

        temp_uri = JSON::Util::URI.normalize_ref(s['$ref'], current_schema.uri)

        # Grab the parent schema from the schema list
        schema_key = temp_uri.to_s.split("#")[0] + "#"

        ref_schema = JSON::Validator.schema_for_uri(schema_key)

        if ref_schema
          uri_fragment = JSON::Util::URI.parse(JSON::Util::URI.unescape_uri(temp_uri)).fragment
          uri = temp_uri
          schema = JSON::Validator.get_referenced_schema(ref_schema, uri_fragment, validator)
        end

        [uri,schema]
      end
    end
  end
end
