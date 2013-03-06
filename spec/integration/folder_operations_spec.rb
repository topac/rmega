require 'integration_spec_helper'

describe 'Folders operations' do
  before :all do
    @session = storage.session
    @parent_node = @session.storage.root_node
    @folder_name = "test_folder_#{rand.denominator}_#{rand.denominator}"
    @folder_node = @session.storage.create_folder @parent_node, @folder_name
  end

  it 'creates a new folder' do
    @folder_node.should be_kind_of Rmega::Node
  end

  it 'finds the folder' do
    node = @session.storage.nodes.find { |n| n.name == @folder_name }
    node.should_not be_nil
  end

  it 'deletes the folder' do
    lambda { @folder_node.delete }.should_not raise_error
  end

  it 'does not find the folder anymore' do
    node = @session.storage.nodes.find { |n| n.name == @folder_name }
    node.should be_nil
  end
end
