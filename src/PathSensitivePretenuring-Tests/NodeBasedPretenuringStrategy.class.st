Class {
	#name : 'NodeBasedPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Tests',
	#package : 'PathSensitivePretenuring-Tests'
}

{ #category : 'api' }
NodeBasedPretenuringStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: aListOfEdges [

    ^ anAllocatorNode isAllocationSite
]
