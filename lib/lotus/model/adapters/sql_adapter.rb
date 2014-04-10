require 'lotus/model/adapters/abstract'
require 'lotus/model/adapters/implementation'
require 'lotus/model/adapters/sql/query'
require 'sequel'

module Lotus
  module Model
    module Adapters
      class SqlAdapter < Abstract
        include Implementation

        def initialize(mapper, uri)
          super
          @connection = Sequel.connect(@uri)
        end

        def create(collection, entity)
          entity.id = _collection(collection)
                        .insert(
                          _serialize(collection, entity)
                        )
          entity
        end

        def update(collection, entity)
          _collection(collection)
            .where(
              _key(collection) => entity.id
            ).update(
              _serialize(collection, entity)
            )
        end

        def delete(collection, entity)
          _collection(collection)
            .where(
              _key(collection) => entity.id
            ).delete
        end

        def all(collection)
          _deserialize(collection, super)
        end

        def find(collection, id)
          _deserialize(
             collection,
            _collection(collection)
              .where(
                _key(collection) => id
              ).first
          ).first
        end

        def first(collection)
          _deserialize(collection, super).first
        end

        def last(collection)
          _deserialize(
             collection,
            _collection(collection)
              .order(
                _key(collection)
              ).last
          ).first
        end

        def clear(collection)
          _collection(collection).delete
        end

        def query(collection, &blk)
          _query.new(collection, _collection(collection), @mapper, &blk)
        end

        private
        def _collection(name)
          @connection[name]
        end

        def _query
          Sql::Query
        end
      end
    end
  end
end
