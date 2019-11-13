xero-api-client
===============

Ruby Xero API Client.

This client handle a issue if you would like to get large amount of journals from Xero.

## Usage

ruby get_data.rb [consumer_key] [from<date>]

Example:

	ruby get_data.rb ABCDEFG1234567 2019-01-20

## Create Windows executable file

	ocra get_data.rb --no-autoload --gem-full --gemfile Gemfile
