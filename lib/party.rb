module Party
  mattr_accessor :application_name

  class Replacer < Arel::Visitors::Visitor
    def create_core(table, projections: [Arel.star], wheres: [])
      Arel::Nodes::SelectCore.new.tap do |select_core|
        select_core.projections = projections
        select_core.source = table
        select_core.wheres = wheres
      end
    end

    def visit_Arel_Nodes_SelectCore(o)
      Arel::Nodes::SelectCore.new.tap do |select_core|
        select_core.projections = visit o.projections
        select_core.source = visit o.source
        select_core.wheres = visit o.wheres
        select_core.groups = visit o.groups
        select_core.windows = visit o.windows
        select_core.havings = visit o.havings
      end
    end

    def visit_Arel_Nodes_SelectStatement(o)
      Arel::Nodes::SelectStatement.new(visit(o.cores)).tap do |select_statement|
        select_statement.orders = visit o.orders
        select_statement.limit = visit o.limit
        select_statement.lock = visit o.lock
        select_statement.offset = visit o.offset
      end
    end

    def visit_Arel_Table(o)
      o.class.new o.name
    end

    def binary(o)
      o.class.new visit(o.left), visit(o.right)
    end

    alias :visit_Arel_Nodes_JoinSource         :binary
    alias :visit_Arel_Nodes_GreaterThan        :binary

    def terminal(o)
      o
    end

    alias :visit_String                        :terminal
    alias :visit_Integer                       :terminal
    alias :visit_Arel_Nodes_SqlLiteral         :terminal
    alias :visit_NilClass                      :terminal

    def visit_Array(o)
      o.map { |i| puts i.class ; visit i }
    end
  end

  module ActiveRecordInstrumentation
    def self.included(instrumented_class)
      instrumented_class.class_eval do
        if instrumented_class.method_defined?(:exec_query)
          alias_method :exec_query_without_secure_queries, :exec_query
          alias_method :exec_query, :exec_query_with_secure_queries
        end
      end
    end

    def secure_queries(sql, transformer)
      arel = ToArel.parse(sql)

      secured_sql = transformer.accept(arel).to_sql

      puts "-> ORIGINAL: " + sql
      puts "-> MODIFIED: " + secured_sql

      secured_sql
    end

    def exec_query_with_secure_queries(sql, *args, **kwargs)
      transformer = Thread.current[:security]

      exec_query_without_secure_queries(
        transformer ? secure_queries(sql, transformer) : sql,
        *args,
        **kwargs
      )
    end
  end

  def self.with_secure_queries(security, &block)
    Thread.current[:security] = security

    yield
  ensure
    Thread.current[:security] = nil
  end
end
