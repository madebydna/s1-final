class Tabular
  
  NoColumnError = Class.new(StandardError)
  NoRowError = Class.new(StandardError)
  
  attr_reader :rows, :column_names, :headers
  
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
  end
  
  def max_x
    @rows.length
  end
  
  def max_y
    @column_names.length
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
  
  def add_row(new_row, pos=nil)
    i = pos.nil? ? max_x : pos
    raise NoRowError, "The row index is out of range" if !(-max_x..max_x).include?(i)
    @rows.insert(i, new_row)
  end
  
  def delete_row(pos)
    raise NoRowError, "The row index is out of range" if !(-max_x..max_x).include?(pos)
    @rows.delete_at(pos)
  end
  
  def select_rows
    @rows = @rows.select {|row| yield row }
  end
  
  def transform_row(pos, &block)
    raise NoRowError, "The row index is out of range" if !(-max_x..max_x).include?(pos)
    new_row = @rows[pos].map {|cell| yield cell }
    @rows[pos].replace(new_row)
  end
  
  # COLUMN METHODS
  
  # columns need to be accessible by header name or index
  # column header name should be an alias for a numeric index
  
  def column_index(pos)
    i = @column_names.index(pos)
    pos = i.nil? ? pos : i
    
    if pos.is_a?(String) || !(-max_y..max_y).include?(pos)
      raise NoColumnError, "The column does not exist or the index is out of range"
    else
      return pos
    end
  end
  
  def column(pos)
    i = column_index(pos)
    @rows.map {|row| row[i] }
  end
  
  def rename_column(old_name, new_name)
    i = @column_names.index(old_name)
    @column_names.delete_at(i)
    @column_names.insert(i, new_name)
  end
  
  # appends or inserts column, depending on whether a position argument is sent in
  
  def add_column(col, pos=nil)
    i = pos.nil? ? max_y : pos
    if headers 
      column_names.insert(i, col.shift)
    end
    @rows.each do |row|
      row.insert(i, col.shift)
    end
  end
  
  def delete_column(pos)
    pos = column_index(pos)
    if headers
      @column_names.delete_at(pos)
    end
    @rows.map {|row| row.delete_at(pos) }
  end
  
  
  def select_columns
    selected = []
    (0..(max_y - 1)).each do |i|
      col = @rows.map {|row| row[i] }
      selected << i if yield col
    end
    @rows.each do |row| 
      row.replace(row.values_at(*selected))
    end
    @column_names = @column_names.values_at(*selected)
  end
  
  def transform_columns(pos, &block)
    pos = column_index(pos)
    @rows.each do |row|
      row[pos] = yield row[pos]
    end
  end
  
  # UTILITY METHODS
  
  def to_table
    @rows.unshift(@column_names)
  end
  
  
end