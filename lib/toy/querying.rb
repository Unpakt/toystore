module Toy
  module Querying
    extend ActiveSupport::Concern

    module ClassMethods
      def get(id)
        key = store_key(id)

        if has_cache?
          value = cache.read(key)
          log_operation('RTG', self, cache, key, value)
        end

        if value.nil?
          value = store.read(key)
          log_operation('GET', self, store, key, value)

          if has_cache?
            cache.write(key, value)
            log_operation('RTS', self, cache, key, value)
          end
        end

        load(key, value)
      end

      def get!(id)
        get(id) || raise(Toy::NotFound.new(id))
      end

      def get_multi(*ids)
        ids.flatten.map { |id| get(id) }
      end

      def get_or_new(id)
        get(id) || new(:id => id)
      end

      def get_or_create(id)
        get(id) || create(:id => id)
      end

      def key?(id)
        key = store_key(id)
        value = store.key?(key)
        log_operation('KEY', self, store, key, value)
        value
      end
      alias :has_key? :key?

      def load(key, attrs)
        return nil if attrs.nil?
        attrs['id'] = key
        allocate.initialize_from_database(attrs)
      end
    end
  end
end