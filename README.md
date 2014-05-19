# Onboard

Checks, downloads, verifies, adds, and commits Drupal contrib modules.

## Installation

Add this line to your application's Gemfile:

    gem 'onboard'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install onboard

## Usage

__COMMANDS:__
```
Commands:
  onboard help [COMMAND]                # Describe available commands or one s...
  onboard modules DOCROOT -c, --core=N  # add default modules to DOCROOT
```

__MODULES:__
```
Usage:
  onboard modules DOCROOT -c, --core=N

Options:
  -a, [--addendum=one two three]   # Add projects to the default list
  -c, --core=N                     # Specify Drupal core version
  -d, [--destination=DESTINATION]  # Specify contrib destination relative to docroot
  -f, [--force=FORCE]              # Force add modules (even if already present)
  -n, [--no=NO]                    # Assume 'no' for all prompts
  -p, [--projects=one two three]   # Pass a custom list of projects
  -s, [--subdir=SUBDIR]            # Specify contrib subdir relative to 'modules'
      [--vc], [--no-vc]            # Enable/Disable version control handling
                                   # Default: true
  -y, [--yes=YES]                  # Assume 'yes' for all prompts

Description:
  `onboard modules` performs multiple tasks when installing contrib modules:

  * Checks for each module in the docroot

  * Downloads the latest version of each module

  * Adds and commits each module

  Default contrib modules: acquia_connector, fast_404, memcache
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/onboard/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
