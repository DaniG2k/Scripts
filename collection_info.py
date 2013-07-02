#!/usr/bin/python
# Written by Daniele Pestilli - July 2013

import sys, os

# Require Python 3
if sys.version_info[0] != 3:
	print("Python 3 is required for this script.")
	print("Please consider upgrading.")
	sys.exit()

if len(sys.argv) == 2:
	home = sys.argv[1]
elif len(sys.argv) > 2:
	sys.exit('Too many arguments passed.')
else:
	home = '/opt/funnelback'

if not os.path.exists(home):
	print('You do not seem to have Funnelback installed in ' + home)
	sys.exit('Exiting.')

def tech_specs():
	sys_info = os.system('uname -a')
	fb_release = os.system('cat ' + home + '/VERSION/funnelback-release')

	print("===== Tech Specs =====\n")
	print('* ' + sys_info)
	print('* ' + fb_release)
	print('* Install dir: ' + home + '\n')

def get_dirs(path):
	return [dir for dir in os.listdir(path) \
	if os.path.isdir(os.path.join(path, dir)) and dir[0] != '.']

def get_collection_triggers():
	conf_dir = home + '/conf'
	commands = ['post_gather_command',
				'post_update_command',
				'post_instant_gather_command',
				'post_instant_update_command']

	# Get a list of collection directories.
	# Omit any directories that start with '.' (hidden)
	collections = get_dirs(conf_dir)

	for collection in collections:
		
		cfg_file = conf_dir + '/' + collection + '/collection.cfg'

		# Check if collection.cfg is missing.
		if not os.path.exists(cfg_file):
			print('WARNING: collection.cfg not found.')
			print('Skipping this directory.')
		else:
			cmd_dic = {}
			with open(cfg_file, 'r') as file:
				for line in file:
					for cmd in commands:
						if cmd in line:
							cmd_dic[cmd] = line.split('=')[1]
			for k, v in cmd_dic.items():
				print(k, v)