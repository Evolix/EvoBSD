# BGP

Deployment of BGP check script with its cron, and a best route log cron.

## Tasks

Everything is in the `tasks/main.yml` file.

## Available variables

The full list of variables (with default values) can be found in `defaults/main.yml`.

  * `bgp_mailto` : email address the output of the script will be sent to when a change is detected
  * `bgp_exclude_grep_command` : facultative grep -v command for some peers not to be checked
