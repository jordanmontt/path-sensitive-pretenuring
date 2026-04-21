Extension { #name : 'Dictionary' }

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
Dictionary >> _pretenured_382025755_at: key ifAbsent: aBlock [
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^ ((array at: (self findElementOrNil: key))
		   ifNil: [ aBlock ]
		   ifNotNil: [ :assoc | assoc ]) value
]

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
Dictionary >> _pretenured_382025755_at: key ifAbsentPut: aBlock [
	"Return the value at the given key.
	If the key is not included in the receiver store and return the result
	of evaluating aBlock as the new value."

	^ self
		  _pretenured_382025755_at: key
		  ifAbsent: [ self _pretenured_382025755_at: key put: aBlock value ]
]

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
Dictionary >> _pretenured_382025755_at: key put: anObject [
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
					put: (Association _pretenured_382025755_key: key value: anObject) ]
		ifNotNil: [ assoc value: anObject ].
	^ anObject
]
