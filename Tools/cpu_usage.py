#! /usr/bin/env python3
import sys
from time import sleep

import csv
import numpy as np
import subprocess
from pprint import pprint


#PATH = os.environ['HOME'] + '/Dropbox/big.Little_optimal_frequencies/data/'

def get_process_pid(name):
	
	pgrep=subprocess.Popen(["pgrep", name],stdout=subprocess.PIPE)
	pid = pgrep.communicate()[0].decode("utf-8")
	
	return pid

def run(name,sleep_time):

	pid = get_process_pid(name)

	threads_info = []

	while pid != '':
		ps = subprocess.Popen(["ps", "-p", str(int(pid)), "-L", "-o", "comm,tid:1,psr:1,pcpu:1", "--no-headers"],stdout=subprocess.PIPE)
		
		threads_info.append(ps.communicate()[0].decode("utf-8"))
		
		pid = get_process_pid(name)

		sleep( sleep_time )

	pprint("tread info")
	pprint(threads_info)
	
	return threads_info

def generate_dic(threads_info):
	d = dict()

	for ti in threads_info:
		spl = ti.split(" ")
		pprint(spl)
		for i in range(1,len(spl),3):
			per = spl[i+2].split('\n')
			pprint(per[0])			
			if spl[i] in d:				
				if spl[i+1] in d[spl[i]]:
					d[spl[i]][spl[i+1]].append(float(per[0]))
				else:
					d[spl[i]][spl[i+1]] = [float(per[0])]
			else:
				d[spl[i]] = {spl[i+1]: [float(per[0])]}

	return d

def generate_usage_matrix(d):

	num_threads = len(d)

	mat = []
	#generate the mean usage value by cores and thread id
	for k,v in d.items():
		el = np.zeros(num_threads)
		for k2,v2 in v.items():
			m = np.mean(v2)
			el[int(k2)] = m
		#mean of all nonzero usage of each thread
		el = np.append(el,np.mean(el[el>0]))
		mat.append(el)

	mat = np.array(mat,ndmin=2)	

	#mean of core usage
	el=[]	
	for i in range(0,num_threads+1):
		c = mat[:,i]
		el.append(np.mean(c[c>0]))

	mat = np.append(mat,el)
	
	return mat.reshape((num_threads+1,num_threads+1))

def generate_hist_matrix(d):

	num_threads = len(d)

	mat = []
	
	for k,v in d.items():
		el = np.zeros(num_threads)
		for k2,v2 in v.items():
			times = len(v2)
			el[int(k2)] = times
		
		el = np.append(el,np.sum(el[el>0]))
		mat.append(el)

	mat = np.array(mat,ndmin=2)	
	
	el=[]	
	for i in range(0,num_threads+1):
		c = mat[:,i]
		el.append(np.sum(c[c>0]))

	mat = np.append(mat,el)

	mat = mat.reshape((num_threads+1,num_threads+1))

	for i in range(0,num_threads+1):
		last = mat[i,num_threads]
		mat[i,:] = mat[i,:] / last

	return mat

def proportional_usage(mat_usage,mat_hist):

	mat = []

	l = mat_usage.shape[0]
	for i in range(0,l):
		usage_l = mat_usage[i,:]
		hist_l = mat_hist[i,:]
		mat.append(usage_l * hist_l)

	return np.array(mat,ndmin=2)		

def save_csv(matrixes, d, file_name):

	fieldnames = ['TID']
	threads_h = np.arange(matrixes[0].shape[0]-1)
	fieldnames.extend(threads_h)
	fieldnames.append('Ave/Per')

	with open(file_name, 'w') as csvfile:
		writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
		writer.writeheader()
		
		keys = list(d.keys())
		keys.append('Stat')
		for mat in matrixes:
			k_in = 0
			for el in mat:
				row_dic = {fieldnames[0]:keys[k_in]}
				for i in range(1,len(fieldnames)):
					row_dic[fieldnames[i]] = round(el[i-1],4)

				writer.writerow(row_dic)
				k_in = k_in + 1
			
			writer.writerow({})


def main():
	name = sys.argv[1]
	sleep_time = sys.argv[2]

	threads_info = run(name,int(sleep_time))
	d = generate_dic(threads_info)

	mat_usage = generate_usage_matrix(d)
	mat_hist = generate_hist_matrix(d)

	mat_pro = proportional_usage(mat_usage,mat_hist)

	pprint("usage")
	pprint(mat_usage)
	pprint("hist")
	pprint(mat_hist)
	pprint("Propor")
	pprint(mat_pro)	

	matrixes = [mat_usage,mat_hist,mat_pro]

	save_csv(matrixes,d,'CPU_USAGE.csv')

main()




