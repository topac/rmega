# Rmega

Ruby library for the Mega.co.nz API


## Usage

```ruby
session = Rmega.create_session 'your_email','your_password'

# And than you access the session with Rmega.current_session

# Fetch all the nodes (files, folders, ecc.)
nodes = Rmega::Node.all

# Find all nodes which name match a regexp
nodes = Rmega::Node.find_all_by_name /my.document/i

# Trash a node
node.move_to_trash

# Gets the public url (the sharable one) of file
node.public_url

# See the attributes of a node
node.attributes

# See the public handle of a node
node.public_handle

# Find all nodes of certain type
# types are: file, dir, root, inbox, trash
files   = Rmega::Node.find_all_by_type :file
folders = Rmega::Node.find_all_by_type :dir

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
