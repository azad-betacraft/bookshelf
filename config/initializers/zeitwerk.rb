# app/errors/ defines classes under the Errors:: namespace (e.g., Errors::NotFoundError).
# Zeitwerk treats app/ subdirectories as autoload roots by default, which would expect
# top-level constants. We removed app/errors/ from the defaults in application.rb
# and re-register it here under the Errors namespace.
module ::Errors; end

Rails.autoloaders.main.push_dir(Rails.root.join("app/errors"), namespace: ::Errors)
