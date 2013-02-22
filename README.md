# Rmega

Ruby library for the Mega.co.nz API.  
For ruby 1.9.3+

<div style="background-color: #000000; border-radius: 8px">
  <img src="https://eu.static.mega.co.nz/images/mega/logo.png" />
</div>


## Usage

```ruby
storage = Rmega.login 'your_email', 'your_password'

# Fetch all the nodes (files, folders, ecc.)
nodes = storage.nodes

# Find all nodes which name match a regexp
nodes = storage.nodes_by_name /my.document/i

# Trash a node
my_node.trash

# Gets the public url (the sharable one) of a file
my_node.public_url

# See the attributes of a node
my_node.attributes

# Download a file
my_node.download '~/Download' # The name of the node is used
my_node.download '~/Download/mydocument_42.zip' # Specify a new name

# Download a file using a given url
storage.download 'https://mega.co.nz/#!cER0GYbD!ZCHruEzLghAcEZuD44Dp0k--6m5duA08Xl4a_bUZYMI', '~/Download'

# Find all nodes of certain type
# types are: file, dir, root, inbox, trash
files   = storage.nodes_by_type :file
folders = storage.nodes_by_type :dir

```


## Installation

Add this line to your application's Gemfile:

    gem 'rmega'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rmega


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
