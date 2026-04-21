Extension { #name : 'Dictionary' }

{ #category : '*PathSensitivePretenuring-Moose-CallerOfNew' }
Dictionary >> _pretenured_499832469_at: key put: anObject [
	"Set the value at key to be anObject.  If key is not found, create a
	new entry for key and set is value to anObject. Answer anObject."

	"(Dictionary new at: #color put: #blue; yourself) >>> (Dictionary new add: #color->#blue; yourself)"

	"(Dictionary new at: #color put: #blue; at: #color put: #red; yourself) >>> (Dictionary new add: #color->#red; yourself)"

	| index assoc |
	index := self findElementOrNil: key.
	assoc := array at: index.
	assoc
		ifNil: [
				self
					atNewIndex: index
					put: (Association _pretenured_499832469_key: key value: anObject) ]
		ifNotNil: [ assoc value: anObject ].
	^ anObject
]

{ #category : '*PathSensitivePretenuring-Moose-CallerOfNew' }
Dictionary >> at: key ifAbsentPut: aBlock [
	"Return the value at the given key.
	If the key is not included in the receiver store and return the result
	of evaluating aBlock as the new value."

	^ self
		  at: key
		  ifAbsent: [ self _pretenured_499832469_at: key put: aBlock value ]
]
