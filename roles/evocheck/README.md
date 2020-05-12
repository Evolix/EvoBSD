# evocheck

Install and run evocheck ; a script for checking various settings automatically.

## Tasks

A separate `exec.yml` file can be imported manually in playbooks or roles to execute the script. Example :

```
- include_role:
    name: evolix/evocheck
    tasks_from: exec.yml
```
