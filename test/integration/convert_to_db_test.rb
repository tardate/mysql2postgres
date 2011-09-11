require 'test_helper'

require 'mysql2psql'

class ConvertToDbTest < Test::Unit::TestCase

  def setup
    seed_test_database
    @options=get_test_config_by_label(:localmysql_to_db_convert_all)
    @mysql2psql = Mysql2psql.new([@options.filepath])
    @mysql2psql.convert
    @mysql2psql.writer.open
  end
  def teardown
    @mysql2psql.writer.close
    delete_files_for_test_config(@options)
  end

  def exec_sql_on_psql(sql, parameters=nil)
    @mysql2psql.writer.conn.exec(sql, parameters)
  end

  def get_boolean_test_record(name)
    exec_sql_on_psql('SELECT * FROM test_boolean_conversion WHERE test_name = $1', [name]).first
  end

  def test_table_creation
    assert_true @mysql2psql.writer.exists?('numeric_types_basics')
    assert_true @mysql2psql.writer.exists?('basic_autoincrement')
    assert_true @mysql2psql.writer.exists?('numeric_type_floats')
  end

  def test_boolean_conversion_to_true
    true_record = get_boolean_test_record('test-true')
    assert_equal 't', true_record['bit_1']
    assert_equal 't', true_record['tinyint_1']
    
    true_nonzero_record = get_boolean_test_record('test-true-nonzero')
    assert_equal 't', true_nonzero_record['tinyint_1']
  end

  def test_boolean_conversion_to_false
    false_record = get_boolean_test_record('test-false')
    assert_equal 'f', false_record['bit_1']
    assert_equal 'f', false_record['tinyint_1']
  end

  def test_boolean_conversion_of_null
    null_record = get_boolean_test_record('test-null')
    assert_nil null_record['bit_1']
    assert_nil null_record['tinyint_1']
  end

end