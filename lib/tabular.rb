class Tabular
  
  attr_reader :rows, :column_names, :columns, :headers
  
  # Should be initialized with an array of arrays and expects the first array to be the column headers
  # if options[:headers] is set to true
  def initialize(data=[], options={})
    @headers = options[:headers]
    if @headers
      @column_names = data.shift
      @rows = data
    else
      @rows = data
    end
    @columns = @rows.transpose
  end
  
  def at(row, col)
    col = column_index(col)
    @rows[row][col]
  end
  
  def [](row, col)
    @rows[row][col]
  end
  
  # ROW METHODS
  
  def row(idx)
    @rows[idx]
  end
  
  def append_row(new_row)
    @rows << new_row
    update_columns
  end
  
  def insert_row(pos, new_row)
    @rows.insert(pos, new_row) 
    update_columns  
  end
  
  def delete_row(pos)
    @rows.delete_at(pos)
    update_columns
  end
  
  def select_rows
    @rows = @rows.select {|row| yield row }
    update_columns
  end
  
  def transform_row(pos, &block)
    new_row = @rows[pos].map {|cell| yield cell }
    @rows[pos].replace(new_row)
    update_columns
  end
  
  # COLUMN METHODS
  
  # columns need to be accessible by header name or index
  # column header name should be an alias for a numeric index
  
  def column_index(pos)
    if pos.is_a?(String) && @headers
      i = @column_names.index(pos)
    elsif pos.is_a?(String) && !@headers
      #raise error if headers not enabled or if column name doesn't exist
    else
      pos
    end
  end
  
  def column(pos)
    i = column_index(pos)
    @columns[i]
  end
  
  def rename_column(old_name, new_name)
    i = @column_names.index(old_name)
    @column_names.delete_at(i)
    @column_names.insert(i, new_name)
  end
  
  # appends column at the right side of the table
  def append_column(new_column)
    if headers
      @column_names << new_column.shift
    end
    @columns << new_column
    update_rows
  end
  
  def insert_column(pos, new_column)
    pos = column_index(pos)
    if headers
      @column_names.insert(pos, new_column.shift)
    end
    @columns.insert(pos, new_column)
    update_rows
  end
  
  def delete_column(pos)
    pos = column_index(pos)
    if headers
      @column_names.delete_at(pos)
    end
    @columns.delete_at(pos)
    update_rows
  end
  
  def select_columns
    @columns = @columns.select {|col| yield col }
    update_rows
  end
  
  def transform_columns(pos, &block)
    pos = column_index(pos)
    new_col = @columns[pos].map {|cell| yield cell }
    @columns[pos].replace(new_col)
    update_rows
  end
  
  # UTILITY METHODS
  
  def update_rows
    @rows = @columns.transpose
  end
  
  def update_columns
    @columns = @rows.transpose
  end
  
  def to_table
    @rows.unshift(@column_names)
  end
  
  
end