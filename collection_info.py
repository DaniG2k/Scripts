#!/usr/bin/python
# Written by Daniele Pestilli - July 2013

import sys, os, platform

# Require Python 3
if sys.version_info[0] != 3:
	print("Python 3 is required for this script.")
	print("Please consider upgrading.")
	sys.exit()

if len(sys.argv) == 2:
	help_flags = ['--help', '-help', '-h']
	if sys.argv[1] in help_flags:
		print('Usage: python3 collection_info.py [FB_HOME]')
		print('FB_HOME defaults to /opt/funnelback if left blank.')
		print("Paths must start with a '/'")
		sys.exit()
	else:
		# Simple check to see if the argument is a path
		if sys.argv[1][0] == '/':
			home = sys.argv[1]
		else:
			sys.exit("The argument you've passed doesn't appear\
			 to be a proper path.")
elif len(sys.argv) > 2:
	sys.exit("""Too many arguments passed.
		Run python3 collection_info.py -h for usage info.
		Exiting.""")
else:
	home = '/opt/funnelback'

def fb_release_path_error_msg(path):
	print("Cannot find Funnelback release file in " + path)
	print("Are you sure you specified the correct Funnelback install path?")

def check_fb_release(path):
	# Return a string containing the FB release
	# or return False.
	try:
		with open(path, 'r') as f:
			fb_release = f.readlines()
		# f.readlines() will return an array object with every line in the file.
		# The FB version info will be the first (and only) line,
		# so return that array element.
		return fb_release[0]
	except IOError:
		fb_release_path_error_msg(path)
		return False

def proper_fb_install(p):
	# Check if path p exists. If it does, check that
	# it's actually a funnelback installation and not
	# some random directory.
	fb_release_path = p+'/VERSION/funnelback-release'
	if not os.path.exists(p):
		print(p + ' does not seem to exist.')
		return False
	elif not check_fb_release(fb_release_path):
		return False
	else:
		print("Funnelback instance found at " + p + '\nProceeding...')
		return True

########################
# Only continue executing the script
# if the home path is correct. Exit otherwise.
if not proper_fb_install(home):
	sys.exit('Exiting.')
########################

def tech_specs():
	sys_info = platform.system() + ' ' + platform.release() + ' ' + platform.machine()
	fb_release = check_fb_release(home+'/VERSION/funnelback-release')
	s = "===== Tech Specs =====\n"
	s += '* ' + sys_info + '\n'
	s += '* ' + fb_release + '\n'
	s += '* Install dir: ' + home + '\n'
	return s

# Get an array of all (unhidden) directories in 'path' variable
def get_dirs(path):
	return [dir for dir in os.listdir(path) \
	if os.path.isdir(os.path.join(path, dir)) and dir[0] != '.']

# Find strings array in a given collection.cfg file.
def find_strings_in_file(strings_a, file):
	dic = {}
	with open(file, 'r') as f:
		for srch_str in strings_a:
			for line in f:
				if srch_str in line:
					# Store the command as key, and the string after
					# the '=' as value.
					dic[srch_str] = line.split('=')[1]
	return dic

def get_collection_triggers():
	cmd_dic = {}
	conf_dir = home + '/conf'
	commands = ['post_gather_command',
				'post_update_command',
				'post_instant_gather_command',
				'post_instant_update_command']
	collections = get_dirs(conf_dir)

	for collection in collections:
		cfg_file = conf_dir + '/' + collection + '/collection.cfg'
		# Check if collection.cfg is missing.
		if not os.path.exists(cfg_file):
			print('WARNING: collection.cfg not found.')
			print('Skipping this directory.')
		else:
			# cmd_dic is a dictionary where the key is the collection name
			# and the valye is another dictionary with the command and 
			# ensuing script.
			cmd_dic[collection] = find_strings_in_file(commands, cfg_file)
	return cmd_dic

for k, v in get_collection_triggers().items():
	print(k,v)
