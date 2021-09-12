#This piece of code performs a simple, straightforward application of the Python version of the GLGA project.
#The Math::Random modul in Perl is required.

import numpy as np
from pyglga_lib import createPop, createPop2, gracefulCross, getGraph, objFcn, glga
import time
import textwrap
import multiprocessing

if __name__=="__main__":

	graph_type=["complete","cycles","path","tree","wheel","random_normal_caterpillar",
	"complete_bipartite","crown","helm","gen_Petersen"]

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


	##Retrieve the number of vertices of the tree
	g_type=graph_type[3]
	g_size=graph_size[g_type][3]

	#Get graph edge list
	graph=getGraph(g_type,g_size)
	print(graph)

	#Inputs
	input={
		"graph":graph,
		"PopSize":30*g_size, # these should always be even.30*g_size
		"Range":g_size,
		"maxGenerations": 1e7,
		"output":'verbose',
		#"output":'silent',
		"swaps":.25,
		"restart_Iter":1e5,
		"restart": True
	}
	

	start=time.time()
	###############Initialize GA
	#pool=multiprocessing.Pool()
	#for i in range(10):
	BestSoln,gens,score=glga(input)
	print(BestSoln)
	#pool.map(glga(input),range(1))
	
	print(time.time()-start)
	#pool.close()
	#pool.join()
