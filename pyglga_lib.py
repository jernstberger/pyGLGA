import numpy as np
#import random
import subprocess
#import time
import math
import numba

def createPop(Popsize,Range):

	#Initializes the population
	population=np.zeros((Popsize,Range))

	#determines a value that is half the size for indexing purposes
	#half=int(Popsize/2)

	#s=time.time()
	#Puts randomly sampled values into the array
	for i in range(0,Popsize):#half):
		#Random sampling without replacement!
		#On (range(0,11),10) returns a list with 10 values between 0 and 10
		#population[i]=random.sample(range(0,Range+1),Range)
		population[i]=np.random.choice(Range+1,Range,replace=False)

	#population=np.array([random.sample(range(0,Range+1),Range) for x in range(Popsize)])
	#population=np.array([np.random.choice(Range+1,Range,replace=False) for x in range(half)])

	#Rather than loop through everything, the bottom half looks like the top
	#	half, only flipped left-to-right
	#population[half:,:]=fliplr.np(population[:half,:])

	#s=time.time()
	#print(time.time()-s)
	return population

def createPop2(Popsize,Range):
	#List comprehension that performs the same action as the loop in createPop
	population=[np.random.choice(Range+1,Range,replace=False) for i in range(Popsize)]

	return np.array(population)


#@njit
def gracefulCross(Pop,frac_swaps,Range):

	Pop=np.array(Pop)

	b=int(.1*len(Pop))
	#print(a)

	#Determine the long dimension of the population
	#half=int(len(Pop)/2) #Presume row dimension is always even

	cross=max(2, math.floor(frac_swaps*(Range)))#floor(cross_frac*n));

	#a=np.random.choice(Range,num_swaps*2,replace=False)

	#Create random pairs of indices to swap in np array
	#a=random.choice(range(0,Range),num_swaps*2)
	a=np.random.choice(Range,cross,replace=False)
	#print(a)
	#Make columnar swap
	#print(Pop[half:,:])
	#print('word')
	Pop[b:,a]=Pop[b:,a[::-1]]
	#print(Pop[half:,:])

	return Pop

def getGraph(graph,size):

	if graph=="complete":
		type="k"
	elif graph=="cycles":
		type="c"
	elif graph=="path":
		type="p"
	elif graph=="tree":
		type="t"
	elif graph=="wheel":
		type="w"
	elif graph=="random_normal_caterpillar":
		type="r"
	elif graph=="complete_bipartite":
		type="kmn"
	elif graph=="crown":
		type="cr"
	elif graph=="helm":
		type="h"
	else:
		type="gp"

	n=size

	A=subprocess.Popen(["./rg.pl","-t",type,"-n",str(n)],stdout=subprocess.PIPE)
	A=A.communicate()[0].strip().decode('ascii')
	A=np.fromstring(A,dtype='int',sep=' ')
	A=np.reshape(A,(int(len(A)/2),2))

	return A

def objFcn(Pop,graph):

	print(graph)
	#edge_list=graph[1::,:]
	#NumEdges=graph[0,1]

	#determine the size of the population
	m2=len(Pop)

	#takes the difference of the two matrices above--forms the matrix of labels then
	#sorts that matrix down each row.
	ind1=edge_list[:,0]-1
	ind2=edge_list[:,1]-1
	sorted_abs_edges=np.sort(np.absolute(Pop[:,ind1]-Pop[:,ind2]))

	#Create a matrix of comparison for the sorted version.
	l=np.arange(NumEdges)+1
	Compare=np.tile(l,(m2,1))

	#Compute the fitness of individual potential solutions.
	B=sorted_abs_edges==Compare

	return np.sum(B,axis=1)/NumEdges

	#print(time.time()-start)
	#Then output that value.
	#return sum(B.T)/NumEdges

#@njit
def elitism(Pop,Range):

	Pop=np.array(Pop)

	#Determine the long dimension of the population
	#Presume len(Pop) is always even
	half=int(.5*len(Pop))

	#Create a new population the size of the original population for the
	#	bottom half of Pop
	Pop[half:,:]=createPop2(half,Range)

	return Pop


def graphSort(Pop, graph):
	#4a.  Evaluate the population using the Objective Functional
	rank=np.array(objFcn(Pop,graph))
	#print(rank)

	#Use argsort to get the indices of order from least to best
	#Use flipud to make them from best to least
	rankSorted=np.argsort(rank)
	#print(rankSorted)
	rankSorted2=rankSorted[::-1]
	#print(rankSorted2)
	rank2=rank[rankSorted2]
	#print(rank2)
	#Sort and score the population
	#print(Pop)
	Pop=Pop[rankSorted2]
	#print(Pop)
	return Pop, np.array(rank2)


def glga(input):

	#Take arguments (numbers of generations, number of elements in graph,
	#  size of population, percentage of elitism, level of screen output,
	#  restart (yes or no), number of gens for restart).
	#  This should be a python dictionary.
	#graph=input["graph"]



	graph=input["graph"]
	#g_size=input["Graph_size"]

	PopSize=input["PopSize"]
	Range=input["Range"]
	maxGenerations=input["maxGenerations"]
	output=input["output"]
	swaps=input["swaps"]
	restart_Iter=input["restart_Iter"]
	restart=input["restart"]

	#Get graph edge list
	#graph=getGraph(g_type,g_size)

	#1b.  Check for missing inputs.
	#2.  Update settings based upon arguments.  Use Python structures as available.

	#start=time.time()
	converge=False #Initialize status as not converged
	generations=1 #Initiatlize generation count

	#Generate the population.
	#s=time.time()
	Pop=createPop2(PopSize,Range)
	#print(time.time()-s)

	if output=='verbose':
#		print('\t\nGens Best\t\t Median')
		print('\nGens\t\t Max\t\t Mean')
	#Enter main loop until max generation count is achieved or solution
	#is found (while convergence hasn't occurred).
	while generations<=(maxGenerations) and not converge:

		#print(Pop)

		Pop,rank=graphSort(Pop,graph)
		#print(Pop)
		#print(rank)

		if max(rank)<1:

			if output=='verbose' and (generations%1000)==0:
				if(generations%1e4)==0:
					print('\nGens\t\t Max\t\t Mean')

				print(generations,'\t\t',f"{max(rank):.6}",'\t',f"{np.mean(rank):.6}")

			if generations==restart_Iter and restart:
				Pop=elitism(Pop,Range)
				#Pop=graphSort(Pop,graph)
			else:
				Pop=gracefulCross(Pop,swaps,Range)
				#Pop=graphSort(Pop,graph)
		else:
			converge=True
			#print(generations, max(rank), np.median(rank))
			if output=='verbose':
				print('A solution was obtained after ',generations,' generations.')


		#Increment gen_count
		generations=generations+1

	#Output the winning solution, the number of generations, and the best score.
	#print(time.time()-start)
	return Pop[0,:],generations,rank[0]
