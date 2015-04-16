FROM centos:centos6

ENV LANG=en_US.UTF-8
<% if @http_proxy %>
ENV http_proxy <%= @http_proxy %>
<% end %>
<% if @https_proxy %>
ENV https_proxy <%= @https_proxy %>
<% end %>

RUN echo 'include_only=.jp' >> /etc/yum/pluginconf.d/fastestmirror.conf

RUN yum clean all
RUN yum install -y sudo openssh-server openssh-clients which curl htop

RUN yum update -y
RUN yum install -y sudo passwd openssh-server openssh-clients bind-utils git tar wget which curl-devel perl-devel autoconf unzip gcc gcc-c++

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN mkdir -p /var/run/sshd

RUN useradd -d /home/<%= @username %> -m -s /bin/bash <%= @username %>
RUN echo <%= "#{@username}:#{@password}" %> | chpasswd
RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN curl -L http://www.opscode.com/chef/install.sh | bash
RUN /opt/chef/embedded/bin/gem install berkshelf

RUN git clone https://github.com/cloudconductor/cloudconductor_init.git /opt/cloudconductor
RUN mkdir -p /opt/cloudconductor/logs
RUN mkdir -p /opt/cloudconductor/tmp

RUN git clone https://github.com/cloudconductor/cloud_conductor_utils.git /opt/cloudconductor/tmp/cloud_conductor_utils

RUN touch ./dummy_iptables
RUN cp ./dummy_iptables /etc/init.d/iptables

ENV PATH /opt/chef/embedded/bin:${PATH}

WORKDIR /opt/cloudconductor/tmp/cloud_conductor_utils

RUN /opt/chef/embedded/bin/rake build
RUN /opt/chef/embedded/bin/gem install ./pkg/*.gem

WORKDIR /opt/cloudconductor/etc

RUN berks vendor /opt/cloudconductor/tmp/cookbooks

WORKDIR /opt/cloudconductor

RUN echo 'export PATTERN_NAME="<%= @cc_pattern %>"' >> ./bootstrap.sh
RUN echo 'export PATTERN_URL="https://github.com/cloudconductor-patterns/<%= @cc_pattern %>.git"' >> ./bootstrap.sh
RUN echo 'export PATTERN_REVISION="develop"' >> ./bootstrap.sh
RUN echo 'export ROLE="<%= @cc_role %>"' >> ./bootstrap.sh
RUN echo 'export CONSUL_SECRET_KEY="<%= @cc_token %>"' >> ./bootstrap.sh
RUN echo 'chef-solo -j ./etc/node_setup.json -c ./etc/solo.rb' >> ./bootstrap.sh

RUN bash -x ./bootstrap.sh
