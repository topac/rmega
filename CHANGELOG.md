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
