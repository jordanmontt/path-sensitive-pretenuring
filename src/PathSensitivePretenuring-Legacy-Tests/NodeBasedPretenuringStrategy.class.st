Class {
	#name : 'NodeBasedPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Legacy-Tests',
	#package : 'PathSensitivePretenuring-Legacy-Tests'
}

{ #category : 'api' }
NodeBasedPretenuringStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: aListOfEdges [

    ^ anAllocatorNode isAllocationSite
]
