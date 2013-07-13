# Rmega

A ruby library for the Mega.co.nz.  
Tested using ruby 1.9.3+ (OpenSSL 0.9.8r+)  
This is the result of a reverse engineering of the MEGA javascript code.
This is a work in progress, further functionality are coming.


Supported features are:
  * Login
  * Searching and browsing
  * Creating folders
  * Download of files and folders (multi-thread)
  * Download with public links (multi-thread)
  * Upload of files (multi-thread)
  * Deleting and trashing


## Installation

  Rmega is distributed via rubygems.org  
  If you have ruby 1.9.3+ installed system wide, just type `gem install rmega`.

## Usage

```ruby
require 'rmega'
```

### Login

```ruby
storage = Rmega.login('your_email', 'your_password')
```

### Browsing

```ruby
# Print the name of the files in the root folder
storage.root.files.each { |file| puts file.name }

# Print the number of files in each folder
storage.root.folders.each do |folder|
  puts "Folder #{folder.name} contains #{folder.files.size} files."
end

# Print the name and the size of the files in the recyble bin
storage.trash.files.each { |file| puts "#{file.name} of #{file.size} bytes" }

# Print the name of all the files (everywhere)
storage.nodes.each do |node|
  next unless node.type == :file
  puts node.name
end
```

### Searching

```ruby
# Search for a file in a specific folder
folder = storage.root.folders[2]
folder.files.find { |file| file.name == "to_find.txt" }

# Search for a file everywhere
storage.nodes.find { |node| node.type == :file and node.name =~ /my_file/i }

# Note: A node can be of type :file, :folder, :root, :inbox and :trash
```

### Download

```ruby
# Download a single file
file = storage.root.files.first
file.download("~/Downloads")
# => Download in progress 15.0MB of 15.0MB (100.0%)

# Download a folder and all its content recursively
folder = storage.nodes.find do |node|
  node.type == :folder and node.name == 'my_folder'
end
folder.download("~/Downloads/my_folder")
```

### Upload

```ruby
# Upload a file to a specific folder
folder = storage.root.folders[3]
folder.upload("~/Downloads/my_file.txt")

# Upload a file to the root folder
storage.root.upload("~/Downloads/my_other_file.txt")
```

### Creating a folder

```ruby
new_folder = storage.root.create_folder("my_documents")

# Create a subfolder of an existing folder
folder = storage.nodes.find do |node|
  node.type == :folder and node.name == 'my_folder'
end
folder.create_folder("my_documents")
```

### Deleting

```ruby
# Delete a folder
folder = storage.root.folders[4]
folder.delete

# Move a folder to the recyle bin
folder = storage.root.folders[4]
folder.trash

# Delete a file
file = storage.root.folders[3].files.find { |f| f.name =~ /document1/ }
file.delete

# Move a file to the recyle bin
file = storage.root.files.last
file.trash
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Copyright

Copyright (c) 2013 Daniele Molteni  
MIT License
