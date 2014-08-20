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
  onboard help [COMMAND]                                  # Describe available commands or one specific command
  onboard projects CODEBASE -c, --core=N -p, --path=PATH  # add projects to CODEBASE
```

__MODULES:__
```
Usage:
  onboard projects CODEBASE -c, --core=N -p, --path=PATH

Options:
  -b, [--branch=BRANCH]          # Specify repository branch to update
  -c, --core=N                   # Specify Drupal core version
  -p, --path=PATH                # Specify project path relative to CODEBASE
  -f, [--force=FORCE]            # Force add modules (even if already present)
  -n, [--no=NO]                  # Assume 'no' for all prompts
  -m, [--modules=one two three]  # Pass a list of modules
  -t, [--themes=one two three]   # Pass a list of themes
      [--vc], [--no-vc]          # Enable/Disable version control handling
                                 # Default: true
  -y, [--yes=YES]                # Assume 'yes' for all prompts

Description:
  `onboard projects` performs multiple tasks when installing contrib projects:

  * Checks for each project in the CODEBASE

  * Downloads the latest version of each project

  * Adds and commits each project
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/onboard/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
