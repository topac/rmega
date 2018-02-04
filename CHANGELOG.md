## 0.2.4

### Changes
* \#25 Fix connection reset on file upload
* \#24 Speed up aes_cbc_mac func

## 0.2.3

### Changes
* Fixed reading options from the configuration file (~/.rmega)
* The max number of parallel threads is now 8

### New Features
* If `rmega-dl` receive a local file as the main args, that file is treated as a text file that must contains a list of mega links
* The download progress bar now distinguishes between allocate, verify and download phase

## 0.2.2

### Changes
* \#17 Fixed download of shared folders

## 0.2.1

### New Features
* \#14 Files and folders can now be renamed with `Node#rename`

### Changes
* `rmega-dl`, `rmega-up` commands now properly traverse the cloud storage when searching for a file/folder to download/upload
* `rmega-dl`: fixed scan for Mega links in a webpage
* The configuration file (~/.rmega) format is changed (from JSON to YAML)
* Dropped dependency to ActiveSupport

## 0.2.0

### New Features
* resumable downloads
* rmega-dl command (with folder download support)
* rmega-up command
* cbc-mac verification (download)
* handle network errors without interrupting downloads/uploads
* cache shared keys
* `Storage#folders` has been removed (use `Storage#shared` that returns only shared folder nodes)

### Changes
* `RequestError` class was removed
* Upload now returns the node `handle`
* `Storage#download` moved to `Rmega#download`

## 0.1.7

* \#9 Fixed decryption of nodes shared by you to others

## 0.1.6

### New Features

* \#7 Rmega now supports shared folders and files.

* The method `Storage#folders` can now be used to get a list of your
  first-level folders + first-level shared folders.

* The error codes list is now updated (up to the number -22).


### Changes

* Rmega will now attempt a request up to 10 times (in case of SocketError
  or if the server is temporary busy) before raising the error.

* Fixed a race condition that cause corrupted downloads
