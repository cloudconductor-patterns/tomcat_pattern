FROM <%= @image %>

ENV LANG=en_US.UTF-8
<% if @http_proxy %>
ENV http_proxy <%= @http_proxy %>
<% end %>
<% if @https_proxy %>
ENV https_proxy <%= @https_proxy %>
<% end %>

RUN echo 'include_only=.jp' >> /etc/yum/pluginconf.d/fastestmirror.conf

# kitchen-docker settings
  # rhel,centos,fedra settings
  RUN yum clean all
  RUN yum install -y sudo openssh-server openssh-clients which curl
  RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
  RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''

RUN useradd -d /home/<%= @username %> -m -s /bin/bash <%= @username %>
RUN echo <%= "#{@username}:#{@password}" %> | chpasswd
RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir -p /etc/sudoers.d
RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/<%= @username %>
RUN chmod 0440 /etc/sudoers.d/<%= @username %>
RUN mkdir -p /home/<%= @username %>/.ssh
RUN chown -R <%= @username %> /home/<%= @username %>/.ssh
RUN chmod 0700 /home/<%= @username %>/.ssh
RUN touch /home/<%= @username %>/.ssh/authorized_keys
RUN chown <%= @username %> /home/<%= @username %>/.ssh/authorized_keys
RUN chmod 0600 /home/<%= @username %>/.ssh/authorized_keys


# follow cloud_conductor_init
WORKDIR /opt/cloudconductor
RUN yum install -y git
RUN git clone https://github.com/cloudconductor/cloud_conductor_init.git /opt/cloudconductor
RUN echo 'cd /opt/cloudconductor' > ./bootstrap.sh
RUN echo 'git checkout develop' >> ./bootstrap.sh
RUN echo 'git pull' >> ./bootstrap.sh
RUN echo 'export PATTERN_NAME="<%= @cc_pattern %>"' >> ./bootstrap.sh
RUN echo 'bash -x ./bin/setup.sh' >> ./bootstrap.sh

# follow prepare.sh from pattern
WORKDIR /opt/cloudconductor
RUN git clone https://github.com/cloudconductor-patterns/<%= @cc_pattern %>.git /opt/cloudconductor/patterns/<%= @cc_pattern %>
RUN echo 'cd /opt/cloudconductor/patterns/<%= @cc_pattern %>' >> ./bootstrap.sh
RUN echo 'git checkout develop' >> ./bootstrap.sh
RUN echo 'git pull' >> ./bootstrap.sh
RUN echo 'bash -x prepare.sh' >> ./bootstrap.sh

RUN bash -x ./bootstrap.sh
