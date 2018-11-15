Role Name
=========

Ansible role for installing Pleora SDK on Ubuntu 14.04 (Modified Installer file is included with the role)

Requirements
------------

As of Nov 2018, only Ubuntu 14.04 is supported.

Role Variables
--------------

``` yaml
# dependencies for installing PleoraSDK
pleora_deps:
  - g++
  - gcc
  - make
  - libqt4-dev

# place to extract the temporary setup file
installer_staging: "/tmp/pleora_setup"

```

Example Playbook
----------------

``` yaml
---

- hosts: all
  tasks:
  - name: Setting up PleoraSDK
    include_role:
      name: pleora
```


License
-------

MIT

Author Information
------------------

Mohit Sharma (Mohitsharma44@gmail.com)
