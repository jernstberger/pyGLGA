#!/usr/bin/python3
#This code is a parallelized version of the py_graphthest_0_1.py code.
#Also, this code has (from lines 21-41) a commented graph (in the appropriate edge labels) for use with the project.

import numpy as np
from pyglga_lib import createPop, createPop2, gracefulCross, getGraph, objFcn, glga, graphSort
import time
import multiprocessing as mp
from functools import partial
import sys
from datetime import date, datetime


def cp1(input,iterable):
	#return np.random.choice(Range+1,Range,replace=False)


	g_type=input["Graph_type"]
	g_size=input["Graph_size"]
	#Get graph edge list
	graph=getGraph(g_type,g_size)
	#g1=[[20,19],
 	# 		[ 1,2],
 	# 		[ 1,3],
	# 		[ 3,4],
	# 		[ 4,5],
	# 		[ 2,6],
	# 		[ 5,7],
 	# 		[ 5,8],
 	# 		[ 4,9],
 	# 		[ 6,10],
 	# 		[ 8,11],
 	# 		[ 8,12],
 	# 		[ 5,13],
 	# 		[10,14],
 	# 		[11,15],
	# 		[11,16],
	# 		[11,17],
	# 		[ 3,18],
	# 		[ 7,19],
	# 		[ 9,20]]
	# graph=np.array(g1)

	input["graph"]=graph

	t1=time.time()
	BestSoln,gens,score=glga(input)
	t2=time.time()-t1
	print(iterable,'\t',f"{gens:10}",'\t',f"{score:.6}",'\t',f"{t2:.6}")


	return BestSoln,graph,iterable,gens,score,t2


def cp_parallel(input):

	print('Graph\t\tGens\t Score\t Time(s)')

	p=mp.Pool()

	iterable=range(100)
	results=p.map(partial(cp1,input),iterable)
	#print(results)

	p.close()
	p.join()

	#print(results)

	return np.array(results)


if __name__=="__main__":

	graph_type=["complete","cycles","path","tree","wheel","random_normal_caterpillar","complete_bipartite","crown","helm","gen_Petersen"]
	graph_size={
		"complete":[5,8,10,15,16,20,24,30],
		"cycles":[8,10,15,20,25,30,40,50],
		"path":[5,10,20,25, 27,28,30,40,50],
		"tree":[5,10,18,20,25,28,30,35,40,50,60,70,80,90,100],
		"wheel":[7,8,10,15,20,30],
		"random_normal_caterpillar":[5,8,10,15,30,45],
		"complete_bipartite":[[5,5],[5,10],[5,20],[10,20]],
		"crown":[5,8,10,15,20,30],
		"helm":[5,8,10,20,30],
		"gen_Petersen":[[5,2],[6,3],[7,3],[8,4],[9,4],[10,5]]
	}

	#Determine Graph Type
	g_type=graph_type[3]

	#Determine Graph Size
	g_size=graph_size[g_type][0]

	#Get graph edge list
	#graph=getGraph(g_type,g_size)
	#graph=

	#Inputs Dictionary
	input={
		"Graph_type":g_type,
		"Graph_size":g_size,
		"PopSize":500,#30*g_size, # these should always be even.
		"Range":g_size,
		"maxGenerations": 1e11,
		"output":'silent',#verbose',
		"swaps":.25,
		"restart_Iter":2e3,
		"restart": True
	}

	#pop=createPop(input["PopSize"],input["Range"])
	#gracefulCross(pop,input["swaps"],input["Range"])

	###############Initialize GA
	#pool=multiprocessing.Pool()
	#for i in range(10):
	#BestSoln,gens,score=glga(input)
	#pool.map(glga(input),range(1))
	#start=time.time()
	res=cp_parallel(input)
	#print(res)

	today=datetime.now()
	d1=today.strftime("%d%m%Y_%H%M%S")
	filename=g_type+str(g_size)+'_'+d1+'.csv'

	gens_Avg=0
	score_Avg=0
	time_Avg=0

	with open(filename, 'w') as f:

		for i in range(100):
			iterable=res[i,2]
			#iter_Avg+=iterable/100
			gens=res[i,3]
			gens_Avg+=gens/100
			score=res[i,4]
			score_Avg+=score/100
			time=res[i,5]
			time_Avg+=time/100
			print(iterable,',',gens,',',score,',',time,file=f)


	print(g_type+ ' graphs of size '+str(g_size))
	print('Mean runtime: ' + f"{time_Avg:.6}"+' secs')
	print('Mean no. generations: ' + f"{gens_Avg:.6}")
	print('Mean score: ' + f"{score_Avg:.6}")
