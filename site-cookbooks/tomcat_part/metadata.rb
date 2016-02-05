name 'tomcat_part'
version          '0.0.2'
description      'Installs/Configures Apache Tomcat and deploys applications'
license          'Apache v2.0'
maintainer       'TIS Inc.'
maintainer_email 'ccndctr@gmail.com'

supports 'centos', '= 6.5'

depends 'cloudconductor'
depends 'yum'
depends 'java'
depends 'tomcat', ">= 0.17"
