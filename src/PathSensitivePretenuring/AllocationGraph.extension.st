Extension { #name : 'AllocationGraph' }

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedSenderChainsUsing: aStrategy [

	self leaves do: [ :leaf | 
		leaf allocatedObjectTypes do: [ :type |
			self traverseLongLivedSenderChainsUsingDFS: aStrategy node: leaf pathUntilNow: {  } type: type ] ]
]

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedSenderChainsUsingDFS: aStrategy node: currentNode pathUntilNow: pathUntilNow type: aType [

	pathUntilNow size > 20 ifTrue: [ ^ self ].

	(aStrategy isAllocationSite: currentNode fromAllocationPath: pathUntilNow) ifTrue: [ 
		currentNode beAllocationSite; appendCallStack: pathUntilNow.
		^ self ].

	(currentNode incomingEdgesForType: aType) do: [ :edge | 
		(pathUntilNow includes: edge) ifFalse: [
			self
				traverseLongLivedSenderChainsUsingDFS: aStrategy
				node: edge sourceNode
				pathUntilNow: (pathUntilNow copyWith: edge)
				type: aType ] ]
]
