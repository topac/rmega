module Rmega
  class RequestError < StandardError
    def initialize(error_code)
      message = self.class.errors[error_code]
      super("Error #{error_code}: #{message}")
    end

    def self.error_code?(number)
      number.respond_to?(:to_i) and number.to_i < 0
    end

    def self.errors
      {
        -1  => 'An internal error has occurred. Please submit a bug report, detailing the exact circumstances in which this error occurred.',
        -2  => 'You have passed invalid arguments to this command.',
        -3  => 'A temporary congestion or server malfunction prevented your request from being processed. No data was altered. Retry. Retries must be spaced with exponential backoff.',
        -4  => 'You have exceeded your command weight per time quota. Please wait a few seconds, then try again (this should never happen in sane real-life applications).',
        -5  => 'The upload failed. Please restart it from scratch.',
        -6  => 'Too many concurrent IP addresses are accessing this upload target URL.',
        -7  => 'The upload file packet is out of range or not starting and ending on a chunk boundary.',
        -8  => 'The upload target URL you are trying to access has expired. Please request a fresh one.',
        -9  => 'Object (typically, node or user) not found',
        -10 => 'Circular linkage attempted',
        -11 => 'Access violation (e.g., trying to write to a read-only share)',
        -12 => 'Trying to create an object that already exists',
        -13 => 'Trying to access an incomplete resource',
        -14 => 'A decryption operation failed (never returned by the API)',
        -15 => 'Invalid or expired user session, please relogin',
        -16 => 'User blocked',
        -17 => 'Request over quota',
        -18 => 'Resource temporarily not available, please try again later'
      }
    end
  end
end
