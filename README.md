About
=====

This is the platform pattern designed to build the system hosts Apache Tomcat based application.
It also supports backup and recovery for PostgreSQL or files. Currently supported:

* CentOS (6.5)
* Java (>= 1.7)
* Apache Tomcat (>= 7)
* PostgreSQL (>= 9.3)

For more information, please visit [official web site](http://cloudconductor.org/).

Requirements
============

Prerequisites
-------------

- cloudconductor (>= 0.3)

How to use patterns
============

You can apply this pattern by using CloudConductor CLI tools or REST API.
Please see [Getting started](http://cloudconductor.org/) in official web site to know
how the parameters you input to CloudConductor CLI tools or REST API are converted into
chef attributes.

Attributes
==========

The attributes not described here have default values, and you can change the value of them if you need.
Please see the attribute files if you want to know what kind of attributes are in this pattern.

Mandatory parameters
--------------------

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|cloudconductor |plain         |Hash           |Common attributes|
|backup\_restore|plain         |Hash           |Backup or restore information|


* cloudconductor

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|applications   |plain         |Hash           |Applications information|

* cloudconductor.applications

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|\<application\_name\>|plain   |Hash           |Application information|

* cloudconductor.applications.\<application_name\>

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|domain         |plain         |String         |Domain of application (ex. app.tomcat.com)|
|type           |plain         |String         |Application type (static or dynamic)
|protocol       |plain         |String         |Service protocol type (http or https)|
|url            |plain         |String         |URL of the application (ex. http://.app.com/app.war)|
|revision       |plain         |String         |Revision of the application (ex. HEAD)|
|pre_deploy     |plain         |String         |Command line executed before the application is deployed|
|post_deploy    |plain         |String         |Command line executed after the application is deployed|
|parameters     |plain         |Hash           |Parameters used by application|

* backup_restore

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|sources        |plain         |Hash           |Source database information|
|destinations   |plain         |Hash           |Destination storage to backup to, or to recovery from|

* backup_restore.sources

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|postgresql     |plain         |Hash           |PostgreSQL database information|

* backup_restore.sources.postgresql

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|user           |plain         |String         |Database username|
|password       |plain         |String         |Database password|

* backup_restore.destinations

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|\<destination name\>|plain    |String         |Destination storage name (s3)|

* backup_restore.destinations.s3

|Parameter      |Style         |Type           |Description  |
|:--------------|:-------------|:--------------|:------------|
|bucket         |plain         |String         |S3 bucket name|
|access\_key\_id|plain         |String         |AWS access key id|
|secret\_access\_key|plain     |String         |AWS secret access key|
|region         |plain         |String         |AWS region (ex. ap-northeast-1)|
|prefix         |plain         |String         |Bucket prefix (ex. backup)|

Example of parameters
---------------------

    {
      "name": "tomcatapp",
      "domain": "app.tomcat.jp",
      "type": "dynamic",
      "protocol": "http",
      "url": "https://app.repository.com/master.tar.gz",
      "revision": "HEAD",
      "pre_deploy": "",
      "post_deploy": "",
      "parameters": "{ \"port\": \"8080\", \"backup_directories\": [\"/var/lib/pgsql/9.3/data\"] }"
      "backup_restore": {
        "sources": {
          "postgresql": {
            "user": "root",
            "password": "dbpassword"
          }
        },
        "destinations": {
          "s3": {
            "bucket": "appbucket",
            "access_key_id": "AKI*****************",
            "secret_access_key": "****************************************",
            "region": "ap-northeast-1",
            "prefix": "app_backup"
          }
        }
      }
    }

Copyright and License
=====================

Copyright 2014 TIS inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


Contact
=======

For more information: <http://cloudconductor.org/>

Report issues and requests: <https://github.com/cloudconductor-patterns/tomcat_pattern/issues>

Send feedback to: <ccndctr@gmail.com>
