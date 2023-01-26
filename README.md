[![Gem Version](https://badge.fury.io/rb/rmega.svg)](https://badge.fury.io/rb/rmega)
[![rmega](https://circleci.com/gh/topac/rmega.svg?style=svg)](https://circleci.com/gh/topac/rmega)


# rmega

Pure ruby library for <img src="https://mega.co.nz/favicon.ico" alt=""/> **MEGA** [https://mega.nz/](https://mega.nz/).  
Works on Linux and OSX with Ruby 2.1+.

## Installation

```
  gem install rmega
```

## Command Line Usage

<img src="https://i.imgur.com/3cjgp4g.gif"/>

Since version 0.2.0 you can use the commands `rmega-dl` and `rmega-up` to download and upload files to MEGA.

 * Downloads are resumable
 * You can download all the links in a given file, e.g. `rmega-dl my_links.txt`
 * Scrape a web page and download all the MEGA links, e.g. `rmega-dl https://www.reddit.com/r/megalinks/foobar`
 * HTTP proxy support
 * Streaming! :beer: You can use a video player (VLC works perfectly) to play videos while downloading them
 * You can use it combined with [torsocks](https://github.com/dgoulet/torsocks/) to download and upload files through the Tor network (slower)

## DSL Usage

### Login

```ruby
require "rmega"
storage = Rmega.login("your@email.com", "your_password")
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

# Print all the nodes (files, folders, etc.) within a spefic folder
folder = storage.root.folders[12]
folder.children.each do |node|
  puts "Node #{node.name} (#{node.type})"
end
```

### Searching

```ruby
# Search for a file within a specific folder
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

# Download a file by url
public_url = 'https://mega.nz/file/MAkg2Iab#bc9Y2U6d93IlRRKVYpcC9hLZjS4G278OPdH6nTFPDNQ'
Rmega.download(public_url, '~/Downloads')
```

### Upload a file

```ruby
# Upload a file to a specific folder
folder = storage.root.folders[3]
folder.upload("~/Downloads/my_file.txt")

# Upload a file to the root folder
storage.root.upload("~/Downloads/my_other_file.txt")
```

### Upload a directory

```ruby
# Upload a directory to a specific folder
folder = storage.root.folders[3]
folder.upload_dir("~/Downloads/my_directory")

# Upload a directory to the root folder
storage.root.upload_dir("~/Downloads/my_other_directory")
```

### Creating a folder

```ruby
# Create a subfolder of the root folder
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

# Empty the trash
unless storage.trash.empty?
  storage.trash.empty!
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
