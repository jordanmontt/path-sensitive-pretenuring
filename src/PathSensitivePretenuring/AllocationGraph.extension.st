Extension { #name : 'AllocationGraph' }

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedSenderChainsUsing: aStrategy [

	"self leaves do: [ :leaf | 
			self traverseLongLivedSenderChainsUsingDFS: aStrategy node: leaf pathUntilNow: ({}) ]."
	
	self leaves do: [ :leaf | 
		leaf allocatedObjectTypes do: [ :type |
			self traverseLongLivedSenderChainsUsingDFS: aStrategy node: leaf pathUntilNow: {  } type: type ] ]
]

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedSenderChainsUsingDFS: aStrategy node: currentNode pathUntilNow: pathUntilNow [

	pathUntilNow size > 10 ifTrue: [ ^ self ].

	(aStrategy isAllocationSite: currentNode fromAllocationPath: pathUntilNow) ifTrue: [ 
		currentNode beAllocationSite; appendCallStack: pathUntilNow.
		^ self ].

	currentNode incomingEdges do: [ :edge | 
		(pathUntilNow includes: edge) ifFalse: [
			self
				traverseLongLivedSenderChainsUsingDFS: aStrategy
				node: edge sourceNode
				pathUntilNow: (pathUntilNow copyWith: edge) ] ]
]

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedSenderChainsUsingDFS: aStrategy node: currentNode pathUntilNow: pathUntilNow type: aType [

	pathUntilNow size > 10 ifTrue: [ ^ self ].
	pathUntilNow ifNotEmpty: [
		(pathUntilNow last allocatedObjectTypes includes: aType) ifFalse: [ ^ self ] ].

	(aStrategy isAllocationSite: currentNode fromAllocationPath: pathUntilNow) ifTrue: [ 
		currentNode beAllocationSite; appendCallStack: pathUntilNow.
		^ self ].
	
	currentNode incomingEdges do: [ :edge | 
		(pathUntilNow includes: edge) ifFalse: [
			self
				traverseLongLivedSenderChainsUsingDFS: aStrategy
				node: edge sourceNode
				pathUntilNow: (pathUntilNow copyWith: edge)
				type: aType ] ]
]
