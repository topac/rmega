require 'rmega/nodes/node'
require 'rmega/nodes/expandable'
require 'rmega/nodes/traversable'

module Rmega
  module Nodes
    class Root < Node
      include Expandable
      include Traversable
    end
  end
end
