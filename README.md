# Rack::Commithash::Endpoint

Rack middleware to return git commit hash.

A simple Rack middleware that exposes the current git commit hash of your application through an HTTP endpoint. This is useful for identifying which version of your application is deployed in various environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-commithash-endpoint'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rack-commithash-endpoint
```

## Usage

### Basic Usage

Add the middleware to your Rack application:

```ruby
# config.ru or similar
require 'rack/commithash/endpoint'

use Rack::Commithash::Endpoint
run YourApp
```

This will make the `/__revision__` endpoint available in all environments where the initializer is loaded.


With this configuration, the commit hash will be available at `/__revision__` and will be read from the `COMMIT_HASH` environment variable.

By default, the response will be in JSON format:

```
GET /__revision__

{"revision":"abc123"}
Content-Type: application/json
```

#### Rails Integration

If you're using Rails, you can add the middleware in an initializer to expose the commit hash endpoint for your app:

```ruby
# config/initializers/commithash_endpoint.rb
Rails.configuration.middleware.insert(0, Rack::Commithash::Endpoint)
```

**Note:**  
By inserting the middleware at position `0`, it is placed before all other middlewares, including `ActionDispatch::SSL` (which is automatically added when `config.force_ssl = true` is set).  
This ensures that the commit hash endpoint is accessible even if SSL redirection is enabled, as requests to this endpoint will not be redirected to HTTPS before reaching the middleware.

### Advanced Configuration

You can customize both the endpoint path and the environment variable name:

```ruby
use Rack::Commithash::Endpoint, path: '/__version__', env_var: 'APP_REVISION'
```

You can also return the commit hash as plain text by setting `json_format: false`:

```ruby
use Rack::Commithash::Endpoint, json_format: false
```

This will return:

```
GET /__revision__

abc123
Content-Type: text/plain
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-commithash-endpoint. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rack-commithash-endpoint/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rack::Commithash::Endpoint project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rack-commithash-endpoint/blob/main/CODE_OF_CONDUCT.md).
