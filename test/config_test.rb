require 'test/helpers'

describe 'defining configuration' do

  before do
    @cr = PluginFu::Config::Receiver.new
  end

  def first
    @cr.all.first or assert false, 'no config specified'
  end

  it "let's you specify a string" do
    @cr.string :foo, "Bar"

    assert_equal :foo, first.key
    assert_equal 'Bar', first.description
    assert_equal :string, first.type
  end

  it "let's you specify an integer" do
    @cr.integer :num_foo, "number of bar"

    assert_equal :integer, first.type
    assert_equal :num_foo, first.key
    assert_equal 'number of bar', first.description
  end

  it "let's you specify a float" do
    @cr.float :foo_precision, "precision of foo"

    assert_equal :float, first.type
    assert_equal :foo_precision, first.key
    assert_equal 'precision of foo', first.description
  end

  it "let's you specify a boolean" do
    @cr.boolean :foo_enabled, "whether to foo"

    assert_equal :boolean, first.type
    assert_equal :foo_enabled, first.key
    assert_equal 'whether to foo', first.description
  end

  it "let's you specify a decimal " do
    @cr.decimal :foo_price, "price of foo"

    assert_equal :decimal, first.type
    assert_equal :foo_price, first.key
    assert_equal 'price of foo', first.description
  end

  it "let's you specify a default value" do
    @cr.string :foo, "Bar", :default => "baz"

    assert_equal :foo, first.key
    assert_equal 'Bar', first.description
    assert_equal 'baz', first.default_value
  end

  it "let's you specify a required value" do
    @cr.string :foo, "Bar", :required => true

    assert_equal :foo, first.key
    assert_equal 'Bar', first.description
    assert first.required?
  end

  it "complains if you specify the same key twice" do
    @cr.string  :foo, "foo"

    assert_raises ArgumentError do
      @cr.integer :foo, "also foo"
    end
  end
end

describe 'accessing configuration values' do

  before do
    @cr = PluginFu::Config::Receiver.new
  end

  it "returns values coerced to the correct type" do
    @cr.string :string, "string"
    @cr.float :float, "float"
    @cr.integer :integer, "integer"
    @cr.boolean :boolean, "boolean"
    @cr.decimal :decimal, "decimal"

    values = {
      :string => 123123,
      :float  => "1.054",
      :integer => "-4",
      :boolean => "false",
      :decimal => "1.55"
    }


    expected = {
      :string => '123123',
      :float  => 1.054,
      :integer => -4,
      :boolean => false,
      :decimal => BigDecimal.new('1.55')
    }

    config = PluginFu::Config.new(@cr.all, values)
    assert_equal expected, config.to_hash
  end

  it "returns default values if none is supplied" do
    @cr.string :foo, "foo", :default => 'cheese'
    config = PluginFu::Config.new(@cr.all, {})
    assert_equal 'cheese', config[:foo]
  end

  it "let's you build defaults from other configuration values" do
    @cr.string :foo, "foo", :default => 'cheese'
    @cr.string :bar, "bar", :default => proc {|c| "#{c[:foo]} burger"}

    config = PluginFu::Config.new(@cr.all, {})
    assert_equal 'cheese burger', config[:bar]

    config = PluginFu::Config.new(@cr.all, {:foo => 'kangaroo'})
    assert_equal 'kangaroo burger', config[:bar]
  end
end

describe 'validating configuration' do

  before do
    @cr = PluginFu::Config::Receiver.new
  end

  it "complains if you supply a config value that isn't part of the defined config" do
    @cr.string :foo, "foo"

    assert_raises PluginFu::Config::UnexpectedValueError do
      PluginFu::Config.new(@cr.all, {:bar => :baz})
    end
  end

  it "complains if you do not supply a config value that is required" do
    @cr.string :foo, "foo", :required => true

    assert_raises PluginFu::Config::RequiredValueError do
      PluginFu::Config.new(@cr.all, {})
    end
  end

  it "complains if you supply a value that can not be co-erced to the correct type" do
    @cr.string :string, "string"
    @cr.float :float, "float"
    @cr.integer :integer, "integer"
    @cr.boolean :boolean, "boolean"
    @cr.decimal :decimal, "decimal"

    assert_raises PluginFu::Config::TypeError do
      PluginFu::Config.new(@cr.all, {:float => 'a string'})
    end

    assert_raises PluginFu::Config::TypeError do
      PluginFu::Config.new(@cr.all, {:integer => '1.45'})
    end

    assert_raises PluginFu::Config::TypeError do
      PluginFu::Config.new(@cr.all, {:boolean => 'cat'})
    end

    assert_raises PluginFu::Config::TypeError do
      PluginFu::Config.new(@cr.all, {:decimal => 'sick dude'})
    end
  end
end
