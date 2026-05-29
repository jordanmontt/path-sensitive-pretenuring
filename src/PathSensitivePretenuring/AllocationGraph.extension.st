Extension { #name : 'AllocationGraph' }

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedSenderChainsUsing: aStrategy [

	self leaves do: [ :leaf |
			leaf allocatedObjectTypes do: [ :type |
					(leaf allocatedSamples
						 select: [ :sample | sample allocatedObjectClass = type ]
						 thenCollect: [ :sample | sample sendersCallStack ]) asSet do: [
							:callstackOfType |
							self
								traverseLongLivedSenderChainsUsingDFS: aStrategy
								node: leaf
								pathUntilNow: callstackOfType
								type: type ] ] ]
]

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedSenderChainsUsingDFS: aStrategy node: currentNode pathUntilNow: pathUntilNow type: aType [

	| depth currentCallStack theCurrentNode |
	depth := 0.
	currentCallStack := OrderedCollection new.
	pathUntilNow asMethodWithOffsetCollection allButFirstDo: [ :methodWithOffset |
			| theEdge |
			depth > 20 ifTrue: [ ^ self ].
			theCurrentNode := (self nodeFor: methodWithOffset method).
			[theEdge := theCurrentNode edgeForOffset: methodWithOffset offset.]
				on: NotFound do: [ :ex | "if the edge if absent..." ^ self ].
			currentCallStack add: theEdge.
			(aStrategy
				 isAllocationSite: theCurrentNode
				 fromAllocationPath: currentCallStack) ifTrue: [
					theCurrentNode
						beAllocationSite;
						appendCallStack: currentCallStack.
					^ self ].
			depth := depth + 1 ]
]
