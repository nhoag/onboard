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
  onboard help [COMMAND]                                   # Describe available commands or one specific command
  onboard lift CODEBASE (coming soon)                      # add lift to CODEBASE
  onboard projects CODEBASE -d, --destination=DESTINATION  # add projects to CODEBASE
  onboard update CODEBASE (coming soon)                    # update projects in CODEBASE
```

__PROJECTS:__
```
Usage:
  onboard projects CODEBASE -d, --destination=DESTINATION

Options:
  -c, [--commit=COMMIT]           # Specify commit object for Git source
  -D, [--delete=DELETE]           # Delete existing projects
  -d, --destination=DESTINATION   # Specify project destination relative to CODEBASE
  -f, [--force=FORCE]             # Force add projects (even if already present)
  -n, [--no=NO]                   # Assume "no" for all prompts
  -p, [--projects=one two three]  # Pass a list of projects
      [--vc], [--no-vc]           # Enable/Disable version control handling
                                  # Default: true
  -y, [--yes=YES]                 # Assume "yes" for all prompts

Description:
  `onboard projects` performs multiple tasks when installing contrib projects:

  * Checks for each project in the CODEBASE

  * Reports patched projects

  * Downloads the latest/stablest version of each project

  * Adds and commits each project
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/onboard/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
