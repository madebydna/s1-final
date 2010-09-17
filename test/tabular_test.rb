require 'rubygems'
require 'yaml'
require 'test/unit'
require 'contest'
require File.join(File.dirname(__FILE__), '..', 'lib', 'tabular')

class TabularTest < Test::Unit::TestCase
  
  context "on initialization" do
      setup do
        @simple_data = [["name", "age", "occupation"], 
                        ["Tom", 32,"engineer"], 
                        ["Beth", 12,"student"], 
                        ["George", 45,"photographer"],
                        ["Laura", 23, "aviator"],
                        ["Marilyn", 84, "retiree"]]
        @simple_table = Tabular.new(@simple_data, :headers => true)
      end
  
      test "table can set header names" do
        assert @simple_table.headers
        assert_equal ["name", "age", "occupation"], @simple_table.column_names
      end
  
      test "table correctly assigns data" do
        assert_equal [["Tom", 32,"engineer"], 
        ["Beth", 12,"student"], 
        ["George", 45,"photographer"],
        ["Laura", 23, "aviator"],
        ["Marilyn", 84, "retiree"]], @simple_table.rows
      end
  
      test "table can be empty" do
        @table = Tabular.new
        assert_equal [], @table.rows
      end
      
      test "without data, rows can be added later" do
        @table = Tabular.new
        @table.append_row([1,2,3])
        assert_equal 1, @table.rows.length
      end
  
  end
  
  context "accessing data" do
    setup do
      @simple_data = [["name", "age", "occupation"], 
                      ["Tom", 32,"engineer"], 
                      ["Beth", 12,"student"], 
                      ["George", 45,"photographer"],
                      ["Laura", 23, "aviator"],
                      ["Marilyn", 84, "retiree"]]                
      @simple_table = Tabular.new(@simple_data, :headers => true)
    end
    
    test "columns can be accessed by their name" do
      assert_equal ["Tom", "Beth", "George", "Laura", "Marilyn"], @simple_table.column("name")
    end
    
    test "columns can be accessed by their ordinal position" do
      assert_equal ["Tom", "Beth", "George", "Laura", "Marilyn"], @simple_table.column(0)
    end
    
    test "cell can be looked up by row and column" do
      assert_equal 12, @simple_table.at(1, 1)
      assert_equal 12, @simple_table[1,1]
      assert_equal 12, @simple_table.at(1,"age")
    end
    
  end
  
  context "row manipulations" do
    setup do
      @simple_data = [["name", "age", "occupation"], 
                      ["Tom", 32,"engineer"], 
                      ["Beth", 12,"student"], 
                      ["George", 45,"photographer"],
                      ["Laura", 23, "aviator"],
                      ["Marilyn", 84, "retiree"]]
      @simple_table = Tabular.new(@simple_data, :headers => true)
    end
    
    test "should be able to retrieve a row" do
      assert_equal ["George", 45,"photographer"], @simple_table.row(2)
    end
    
    test "should be able to append a row at the end of the table" do
      current_number_of_rows = @simple_table.rows.length
      @simple_table.append_row(["Mary", 40, "teacher"])
      assert_equal (current_number_of_rows + 1), @simple_table.rows.length
    end
    
    test "should be able to insert a row at any position in the table" do
      third_row = @simple_table.row(2)
      @simple_table.insert_row(2, ["Jane", 19, "shop assistant"])
      assert_not_same third_row, @simple_table.row(2)
      assert_equal ["Jane", 19, "shop assistant"], @simple_table.row(2)
    end
    
    test "should be able to delete any row" do
      current_number_of_rows = @simple_table.rows.length
      @simple_table.delete_row(2)
      assert_equal (current_number_of_rows -1), @simple_table.rows.length
    end
    
    test "should be able to run a transformation on a row which changes its content" do
      @simple_table.transform_row(0) do |cell|
        cell.is_a?(String) ? cell.reverse : cell
      end
      assert_equal "moT", @simple_table.at(0,0)
    end    
  end
  
  context "column manipulations" do 
    setup do
      @simple_data = [["name", "age", "occupation"], 
                      ["Tom", 32,"engineer"], 
                      ["Beth", 12,"student"], 
                      ["George", 45,"photographer"],
                      ["Laura", 23, "aviator"],
                      ["Marilyn", 84, "retiree"]]
      @simple_table = Tabular.new(@simple_data, :headers => true)
    end
    
    test "can access a column" do
      assert_equal ["Tom", "Beth", "George", "Laura", "Marilyn"],  @simple_table.column("name")
    end
    
    test "can rename a column" do
      @simple_table.rename_column("name", "first name")
      assert_equal ["first name", "age", "occupation"], @simple_table.column_names
    end
    
    test "can append a column" do
      to_append = ["location", "Italy", "Mexico", "USA", "Finland", "China"]
      @simple_table.append_column(to_append)
      assert_equal ["name", "age", "occupation", "location"], @simple_table.column_names
      assert_equal 4, @simple_table.rows.first.length
    end
    
    test "can insert a column at any position" do
      to_append = ["last name", "Brown", "Crimson", "Denim", "Ecru", "Fawn"]
      @simple_table.insert_column(1, to_append)
      assert_equal ["name", "last name", "age", "occupation"], @simple_table.column_names
      assert_equal "Brown", @simple_table.at(0,1)
    end
    
    test "can delete a column from any position" do
      @simple_table.delete_column(1)
      assert_equal ["name", "occupation"], @simple_table.column_names
      assert_equal ["Tom", "engineer"], @simple_table.row(0)
    end
    
    test "can run a transformation on a column which changes its content" do
      # age everyone by five years
      expected_ages = @simple_table.column("age").map {|a| a+= 5 }
      @simple_table.transform_columns("age") do |col|
        col += 5
      end
      assert_equal expected_ages, @simple_table.column("age")
    end
    
  end
  
  context "filtering rows and columns" do
    
    setup do
      @simple_data = [["name", "age", "occupation"], 
                      ["Tom", 32,"engineer"], 
                      ["Beth", 12,"student"], 
                      ["George", 45,"photographer"],
                      ["Laura", 23, "aviator"],
                      ["Marilyn", 84, "retiree"]]
      @simple_table = Tabular.new(@simple_data, :headers => true)
    end
    
    test "can select rows by some criteria" do
      # select people under 35
      @simple_table.select_rows do |row|
        row[1] < 35
      end
      assert !["Marilyn", 84, "retiree"].include?(@simple_table.rows)
    end
    
    test "can select columns by some criteria" do
      # should select only columns that have numeric data
      @simple_table.select_columns do |col|
        col.all? {|c| Numeric === c } 
      end
      assert_equal 1, @simple_table.columns.length
    end
    
  end
  
  
  
end