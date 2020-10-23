# OSPF

Deployment of OSPF check scripts with their cron.

## Tasks

Everything is in the `tasks/main.yml` file.

## Available variables

The full list of variables (with default values) can be found in `defaults/main.yml`.

*   `ospf_mailto` : email address the output of the scripts will be sent to when a change is detected
*   `ospf_sed_command` : facultative sed command to modify the ospfctl output and add a name to IPs
