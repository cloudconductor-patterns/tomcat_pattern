# -*- coding: utf-8 -*-

import os
import json
import unittest
import mock
import test_helper

import event_handler

test_root = os.path.join( os.path.join(test_helper.pattern_root, 'serverspec' ))

class TestEventHandler(unittest.TestCase):

  def setup(self):
    self.seq = range(10)

  def test_initialize(self):
    self.assertEqual( event_handler.pattern_name, 'tomcat_pattern' )
    self.assertEqual( event_handler.pattern_root, test_helper.pattern_root )

  @mock.patch('event_handler.execute_serverspec')
  @mock.patch('event_handler.execute_chef')
  def test_execute_with_spec(self, chef, spec):
    spec.return_value = 0
    chef.return_value = 1

    roles = ['web', 'ap', 'db']

    ret = event_handler.execute(roles, 'spec')

    self.assertEqual( spec.call_count, 1 )
    self.assertEqual( spec.call_args, ( (roles, ), {} ) )
    self.assertEqual( ret, 0 )

  @mock.patch('event_handler.execute_serverspec')
  @mock.patch('event_handler.execute_chef')
  def test_execute_with_chef(self, chef, spec):
    spec.return_value = 1
    chef.return_value = 0

    roles = ['web', 'ap', 'db']

    ret = event_handler.execute(roles, 'setup')

    self.assertEqual( chef.call_count, 1 )
    self.assertEqual( chef.call_args, ((roles, 'setup', ), {}) )
    self.assertEqual( ret, 0 )

  @mock.patch('os.path.exists')
  @mock.patch('event_handler.run_chefsolo')
  def test_execute_chef(self, run_chefsolo, file_exists):
    run_chefsolo.return_value = 0

    def side_effect( file_path ):
      if file_path == os.path.join( test_helper.pattern_root, 'roles', 'web_setup.json' ) :
        return True
      elif file_path == os.path.join( test_helper.pattern_root, 'roles', 'db_setup.json' ) :
        return True
      else:
        return False

    file_exists.side_effect = side_effect

    roles = ['web', 'ap', 'db']

    ret = event_handler.execute_chef(roles, 'setup')

    self.assertEqual( file_exists.call_count, 4 )
    self.assertEqual( file_exists.call_args_list, \
        [((os.path.join( test_helper.pattern_root, 'roles', 'web_setup.json' ),),), \
        ((os.path.join( test_helper.pattern_root, 'roles', 'ap_setup.json' ),),), \
        ((os.path.join( test_helper.pattern_root, 'roles', 'db_setup.json' ),),), \
        ((os.path.join( test_helper.pattern_root, 'roles', 'all_setup.json' ),),)] )

    self.assertEqual( run_chefsolo.call_count, 2)
    self.assertEqual( run_chefsolo.call_args_list, \
        [(('web', 'setup'),), (('db', 'setup'),)] )
    self.assertEqual( ret, 0 )

  @mock.patch('os.path.exists')
  @mock.patch('event_handler.events')
  @mock.patch('event_handler.system')
  def test_execute_serverspec_in_configure_phase(self, system, events, file_exists):
    events.return_value = ['configure']
    system.return_value = 0


    def side_effect(file_path):
      if file_path == os.path.join( test_root, 'spec', 'web', 'web_configure_spec.rb' ) :
        return True
      elif file_path == os.path.join( test_root, 'spec', 'db', 'db_configure_spec.rb' ) :
        return True
      else:
        return False

    file_exists.side_effect = side_effect

    roles = ['web', 'ap', 'db']

    ret = event_handler.execute_serverspec( roles )

    self.assertEqual( events.call_count, 1)

    self.assertEqual( file_exists.call_count, 4)
    self.assertEqual( file_exists.call_args_list, \
        [((os.path.join( test_root, 'spec', 'all', 'all_configure_spec.rb' ),),),\
        ((os.path.join( test_root, 'spec', 'web', 'web_configure_spec.rb' ),),), \
        ((os.path.join( test_root, 'spec', 'ap', 'ap_configure_spec.rb' ),),), \
        ((os.path.join( test_root, 'spec', 'db', 'db_configure_spec.rb' ),),)] )

    self.assertEqual( system.call_count, 2)
    self.assertEqual( system.call_args_list, \
        [(('cd ' + test_root + '; rake spec[web,configure]', ),), \
        (('cd ' + test_root + '; rake spec[db,configure]',),)] )

    self.assertEqual( ret, 0 )

  @mock.patch('os.path.exists')
  @mock.patch('event_handler.events')
  @mock.patch('event_handler.system')
  def test_execute_serverspec_in_deploy_phase(self, system, events, file_exists):
    events.return_value = ['configure', 'deploy']
    system.return_value = 0

    def side_effect(file_path):
      if file_path == os.path.join( test_root, 'spec', 'web', 'web_configure_spec.rb' ) :
        return True
      elif file_path == os.path.join( test_root, 'spec', 'db', 'db_configure_spec.rb' ) :
        return True
      elif file_path == os.path.join( test_root, 'spec', 'web', 'web_deploy_spec.rb' ) :
        return True
      elif file_path == os.path.join( test_root, 'spec', 'db', 'db_deploy_spec.rb' ) :
        return True
      else:
        return False

    file_exists.side_effect = side_effect

    roles = ['web', 'ap', 'db']

    ret = event_handler.execute_serverspec( roles )

    self.assertEqual( events.call_count, 1)

    self.assertEqual( file_exists.call_count, 8)
    self.assertEqual( file_exists.call_args_list, \
        [((os.path.join( test_root, 'spec', 'all', 'all_configure_spec.rb' ),),),\
        ((os.path.join( test_root, 'spec', 'all', 'all_deploy_spec.rb' ),),), \
        ((os.path.join( test_root, 'spec', 'web', 'web_configure_spec.rb' ),),), \
        ((os.path.join( test_root, 'spec', 'web', 'web_deploy_spec.rb' ),),), \
        ((os.path.join( test_root, 'spec', 'ap', 'ap_configure_spec.rb' ),),), \
        ((os.path.join( test_root, 'spec', 'ap', 'ap_deploy_spec.rb' ),),), \
        ((os.path.join( test_root, 'spec', 'db', 'db_configure_spec.rb' ),),), \
        ((os.path.join( test_root, 'spec', 'db', 'db_deploy_spec.rb' ),),)] )

    self.assertEqual( system.call_count, 4)
    self.assertEqual( system.call_args_list, \
        [(('cd ' + test_root + '; rake spec[web,configure]', ),), \
        (('cd ' + test_root + '; rake spec[web,deploy]', ),), \
        (('cd ' + test_root + '; rake spec[db,configure]', ),), \
        (('cd ' + test_root + '; rake spec[db,deploy]',),)] )

    self.assertEqual( ret, 0 )

  @mock.patch('event_handler.read_parameters')
  def test_events(self, read_prms):
    read_prms.return_value = {}
    self.assertEqual( event_handler.events(), ['configure'] )

    read_prms.result_value = {'cloudconductor': None}
    self.assertEqual( event_handler.events(), ['configure'] )

    read_prms.return_value = {'cloudconductor': {'applications': None}}
    self.assertEqual( event_handler.events(), ['configure'] )

    read_prms.return_value = {'cloudconductor': {'applications': {}}}
    self.assertEqual( event_handler.events(), ['configure', 'deploy'] )

  @mock.patch('event_handler.file_open')
  def test_create_chefsolo_config_file(self, file_open):
    dummy_obj =  mock.Mock(spec=file)
    file_open.return_value = dummy_obj

    ret = event_handler.create_chefsolo_config_file('web')
    self.assertEqual( ret, os.path.join( test_helper.pattern_root, 'solo.rb') )

    self.assertEqual( file_open.call_count, 1 )
    self.assertEqual( file_open.call_args, ((os.path.join( test_helper.pattern_root, 'solo.rb'), 'w'), ) )

    self.assertEqual( dummy_obj.write.call_args_list, \
        [(('ssl_verify_mode :verify_peer\n',),), \
        (('role_path \''+ test_helper.pattern_root +'/roles\'\n', ),), \
        (('log_level :info\n', ),), \
        (('log_location \''+ test_helper.pattern_root +'/logs/tomcat_pattern_web_chef-solo.log\'\n', ),), \
        (('file_cache_path \''+ test_helper.pattern_root +'/tmp/cache\'\n', ),), \
        (('cookbook_path [\''+ test_helper.pattern_root +'/cookbooks\', \''+ test_helper.pattern_root +'/site-cookbooks\']', ),)] )

    self.assertEqual( dummy_obj.close.call_count, 1 )

  @mock.patch('event_handler.read_servers')
  @mock.patch('event_handler.read_parameters')
  @mock.patch('event_handler.file_open')
  def test_create_chefsolo_node_file_setup(self, file_open, read_prms, read_srvs):
    dummy_obj = mock.Mock(spec=file)
    file_open.return_value = dummy_obj

    read_prms.return_value = {'cloudconductor': {'patterns': {'tomcat_pattern': { \
        'user_attributes': {'key1': 'value1', 'key2': {'key3': 'value3'}}}}}}

    read_srvs.return_value = {'testserver': {'ip': '192.168.0.1'}}

    # creates node file in case of setup
    ret = event_handler.create_chefsolo_node_file('web', 'setup')
    self.assertEqual( ret, os.path.join( test_helper.pattern_root, 'node.json') )

    self.assertEqual( read_prms.call_count, 1 )
    self.assertEqual( read_srvs.call_count, 0 )

    self.assertEqual( file_open.call_count, 1 )
    self.assertEqual( file_open.call_args, ((os.path.join( test_helper.pattern_root, 'node.json'), 'w'),) )

    self.assertEqual( dummy_obj.write.call_count, 1 )
    self.assertEqual( dummy_obj.write.call_args, \
        (( json.dumps( {'cloudconductor': {'patterns': {'tomcat_pattern': { \
        'user_attributes': {'key1': 'value1', 'key2': {'key3': 'value3'}}}}}, \
        'run_list': ['role[web_setup]']} ), ),) )

    self.assertEqual( dummy_obj.close.call_count, 1 )

  @mock.patch('event_handler.read_servers')
  @mock.patch('event_handler.read_parameters')
  @mock.patch('event_handler.file_open')
  def test_create_chefsolo_node_file_configure(self, file_open, read_prms, read_srvs):
    dummy_obj = mock.Mock(spec=file)
    file_open.return_value = dummy_obj

    read_prms.return_value = {'cloudconductor': {'patterns': {'tomcat_pattern': { \
        'user_attributes': {'key1': 'value1', 'key2': {'key3': 'value3'}}}}}}

    read_srvs.return_value = {'testserver': {'ip': '192.168.0.1'}}

    # creates node file in case of not setup
    ret = event_handler.create_chefsolo_node_file('web', 'configure')
    self.assertEqual( ret, os.path.join( test_helper.pattern_root, 'node.json') )

    self.assertEqual( read_prms.call_count, 1 )
    self.assertEqual( read_srvs.call_count, 1 )

    self.assertEqual( file_open.call_count, 1 )
    self.assertEqual( file_open.call_args, ((os.path.join( test_helper.pattern_root, 'node.json'), 'w'),) )

    self.assertEqual( dummy_obj.write.call_count, 1 )
    self.assertEqual( dummy_obj.write.call_args, \
        (( json.dumps( {'cloudconductor': {'patterns': {'tomcat_pattern': { \
        'user_attributes': {'key1': 'value1', 'key2': {'key3': 'value3'}}}}, \
        'servers': {'testserver': {'ip': '192.168.0.1'}}}, \
        'key1': 'value1', 'key2': {'key3': 'value3'}, \
        'run_list': ['role[web_configure]']} ), ),) )

    self.assertEqual( dummy_obj.close.call_count, 1 )

  @mock.patch('event_handler.create_chefsolo_node_file')
  @mock.patch('event_handler.create_chefsolo_config_file')
  @mock.patch('event_handler.system')
  def test_run_chefsolo(self, system, config_file, node_file):
    system.return_value = 0
    config_file.return_value = '/tmp/test/solo.rb'
    node_file.return_value = '/tmp/test/node.json'

    ret = event_handler.run_chefsolo( 'web', 'setup' )

    self.assertEqual( ret, 0 )

    self.assertEqual( config_file.call_count, 1 )
    self.assertEqual( config_file.call_args, (('web', ),) )

    self.assertEqual( node_file.call_count, 1 )
    self.assertEqual( node_file.call_args, (('web', 'setup'),) )

    self.assertEqual( system.call_count, 2 )
    self.assertEqual( system.call_args_list, \
        [(('cd '+ test_helper.pattern_root + '; berks vendor ./cookbooks', ),), \
        (('chef-solo -c /tmp/test/solo.rb -j /tmp/test/node.json', ),)] )


if __name__ == '__main__':
  suite = unittest.TestLoader().loadTestsFromTestCase(TestEventHandler)
  unittest.TextTestRunner(verbosity=2).run(suite)
