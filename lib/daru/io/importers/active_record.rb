require 'daru'
require 'daru/io/base'

module Daru
  module IO
    module Importers
      class ActiveRecord < Base
        # Imports a +Daru::DataFrame+ from an ActiveRecord Relation
        #
        # @param relation [ActiveRecord::Relation] A relation to be used to load
        #   the contents of DataFrame
        # @param fields [String or Array of Strings] A set of fields to load from.
        #
        # @return A +Daru::DataFrame+ imported from the given relation and fields
        #
        # @example Importing from an ActiveRecord relation without specifying fields
        #   df = Daru::IO::Importers::ActiveRecord.new(Account.all).call
        #   df
        #
        #   #=> #<Daru::DataFrame(2x3)>
        #   #=>        id  name   age
        #   #=>   0     1 Homer    20
        #   #=>   1     2 Marge    30
        #
        # @example Importing from an ActiveRecord relation by specifying fields
        #   df = Daru::IO::Importers::ActiveRecord.new(Account.all, :id, :name).call
        #   df
        #
        #   #=> #<Daru::DataFrame(2x2)>
        #   #=>        id  name
        #   #=>   0     1 Homer
        #   #=>   1     2 Marge
        def initialize(relation, *fields)
          super(binding)
        end

        def call
          if @fields.empty?
            records = @relation.map do |record|
              record.attributes.symbolize_keys
            end
            return Daru::DataFrame.new(records)
          else
            @fields.map!(&:to_sym)
          end

          vectors = @fields.map { |name| [name, Daru::Vector.new([], name: name)] }.to_h

          Daru::DataFrame.new(vectors, order: @fields).tap do |df|
            @relation.pluck(*@fields).each do |record|
              df.add_row(Array(record))
            end
            df.update
          end
        end
      end
    end
  end
end

require 'daru/io/link'
Daru::DataFrame.register_io_module :from_activerecord, Daru::IO::Importers::ActiveRecord