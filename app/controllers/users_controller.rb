class UsersController < ApplicationController
  around_action :with_secure_queries

  def index
    render json: User.all
  end

  private

  def with_secure_queries
    transformer = Class.new(Party::Replacer) do
      def table_transformation_for(table)
        transformations = {
          User.table_name => -> do
            {
              wheres: [
                Arel::Nodes::Equality.new(Arel.sql('active'), Arel::Nodes::True.new)
              ]
            }
          end
        }

        transformations[table.name]
      end

      def visit_Arel_Table(table)
        if transformation = table_transformation_for(table)
          replacement_table = create_core [table], **transformation.()
          Arel::Nodes::TableAlias.new(Arel::Nodes::Grouping.new(replacement_table), table.name)
        else
          table
        end
      end
    end

    ::Party.with_secure_queries(transformer.new) { yield }
  end
end
