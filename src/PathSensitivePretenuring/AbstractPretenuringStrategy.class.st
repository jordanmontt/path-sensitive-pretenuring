Class {
	#name : 'AbstractPretenuringStrategy',
	#superclass : 'Object',
	#classVars : [
		'KernelPackages'
	],
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'class initialization' }
AbstractPretenuringStrategy class >> fileName [
   "Return a string"

   ^ self subclassResponsibility
]

{ #category : 'class initialization' }
AbstractPretenuringStrategy class >> initialize [

    | repo |
    repo := IceRepository registry detect: [ :each | each name = 'pharo' ].
    KernelPackages := repo workingCopy packages collect: #packageName
]

{ #category : 'private' }
AbstractPretenuringStrategy >> edgesHaveSameAllocatedObjectTypes: aListOfEdges [

    | typesInAllocatorEdge |
    aListOfEdges size <= 1 ifTrue: [ ^ true ].

    typesInAllocatorEdge := aListOfEdges first allocatedObjectTypes.
    typesInAllocatorEdge ifEmpty: [ ^ true ].

    ^ aListOfEdges allButFirst allSatisfy: [ :edge |
        | edgeTypes |
        edgeTypes := edge allocatedObjectTypes.
        typesInAllocatorEdge allSatisfy: [ :type | edgeTypes includes: type ] ]
]

{ #category : 'private' }
AbstractPretenuringStrategy >> extractLongLivedSendersChains: allocationGraph [

    | allocationSiteNodes sendersToPretenure |
    allocationSiteNodes := allocationGraph nodes select: #isAllocationSite.
    sendersToPretenure := OrderedCollection new.

    allocationSiteNodes do: [ :node |
            sendersToPretenure addAll: (node allocationCallStacks collect: [ :aCollection |
                     aCollection collect: [ :edge |
                         IllMethodWithOffset method: edge sourceNode method offset: edge offset ] ]) ].

    sendersToPretenure := sendersToPretenure select: #isNotEmpty.
    ^ sendersToPretenure
]

{ #category : 'private' }
AbstractPretenuringStrategy >> hasOnlyLongLivedEdges: pathUntilNow [

    ^ pathUntilNow allSatisfy: #isLongLived
]

{ #category : 'api' }
AbstractPretenuringStrategy >> isAllocationSite: anAllocatorNode fromAllocationPath: aListOfEdges [
	"It is expected that the allocation paht is set by this method."

	^ self subclassResponsibility
]

{ #category : 'private' }
AbstractPretenuringStrategy >> isKernelMethod: anAllocationGraphNode [

    ^ KernelPackages includes: anAllocationGraphNode method package name
]

{ #category : 'instance creation' }
AbstractPretenuringStrategy >> newClassificationAlgorithm [

	^ MerlinPretenuringAdviceAlgorithm new
]

{ #category : 'api' }
AbstractPretenuringStrategy >> setUpForGraph: allocationGraph [

    
]
