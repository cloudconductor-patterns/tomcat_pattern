CHANGELOG
=========

## version 2.0.1 (2016/04/14)

  - Download tomcat-connector from archive subdomain on apache.org

## version 2.0.0 (2016/03/30)

  - Support CloudConductor v2.0.
  - Support CentOS 7.x
  - Support latest Chef
  - Support [Terraform](https://www.terraform.io/)
  - Support [Wakame-vdc](http://wakame-vdc.org/)

## version 1.1.0 (2015/09/30)

  - Support CloudConductor v1.1.
  - Remove the event_handler.sh, modified to control by the Metronome (task order control tool).Therefore, add the requirements(task.yml file etc.) to control from the Metronome.
  - Fix malformed json of service definitions for consul.
  - Remove cloud_conductor_util gem from the required gems.
  - Add the requirements for test run in test-kitchen.
  - Change to enable JMX access port for monitoring by Zabbix.

## version 1.0.1 (2015/06/18)

  - Support to pre/post deploy script.
  - Add dependency to build resources in the correct order.

## version 1.0.0 (2015/03/27)

  - Support CloudConductor v1.0.
  - Backup features have been omitted from this pattern. Use optional pattern (e.g. amanda_pattern) in conjuction with this pattern if you need backup features.

## version 0.3.3 (2015/02/26)

  - Fix community cookbook version

## version 0.3.2 (2014/12/24)

  - Support latest serverspec.
  - Add default data directory for postgresql.
  - Add default CIDR to CloudConductorLocation parameter.
  - Add dependencies between SubnetRouteTableAssociation and EIP to specify remove order.
  - Brush up chef recipes on apache_part and postgresql_part.

## version 0.3.1 (2014/11/17)

  - Modify default_attribute for opscode cookbooks changed in postgresql_part

## version 0.3.0 (2014/10/31)

  - First release of this pattern that contains tomcat and postgresql
