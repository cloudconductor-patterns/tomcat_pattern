# -*- coding: utf-8 -*-

import os
file_dir = os.path.dirname( __file__ )
test_root = os.path.abspath(os.path.join( file_dir, '..', '..' ))
pattern_root = os.path.abspath(os.path.join( test_root, '..' ))

import sys
sys.path.append( os.path.join( pattern_root, 'lib' ))
