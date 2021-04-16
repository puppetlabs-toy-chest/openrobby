#!/bin/bash
parent_dir=`pwd`
for app in "sms_code" "ldap_wrapper" "ldap_search" "ldap_write" "robby_web"
do
  echo "Running tests for ${app}"
  cd "${parent_dir}/apps/${app}"
  mix test
done
