  def column_exists?(table_name, column_name)
    table = DB[table_name]
    table.columns.include?(column_name)
  end

  def create_tables
    DB.create_table?(:payments) do
      primary_key :id
      String :correlation_id, unique: true, null: false
      Float :amount, null: false
      String :processed_by, null: false
      Time :requested_at, null: true
      Time :created_at, default: Sequel::CURRENT_TIMESTAMP
      Time :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end

    # Adiciona índices se não existirem (verificando pelo nome do índice)
    indexes = DB.indexes(:payments)
    DB.add_index :payments, :requested_at, name: :idx_payments_requested_at unless indexes.key?(:idx_payments_requested_at)
    DB.add_index :payments, :processed_by, name: :idx_payments_processed_by unless indexes.key?(:idx_payments_processed_by)
    DB.add_index :payments, [:requested_at, :processed_by], name: :idx_payments_requested_at_processed_by unless indexes.key?(:idx_payments_requested_at_processed_by)
  end

  def update_tables
    # Example of updating a table, if needed
    # DB.alter_table(:items) do
    #     # Add a new column if it doesn't exist
    #     add_column :category, String unless column_exists?(:items, :category) 
    #     add_column :description, String unless column_exists?(:items, :description) 
    #   end
  end


  def delete_columns
    # Example of deleting a column, if needed
    # DB.alter_table(:items) do
    #   drop_column :test if column_exists?(:items, :test)
    # end
  end


  def define_tables
    create_tables
    update_tables
    delete_columns
  end