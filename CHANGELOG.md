CHANGELOG
=========

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
