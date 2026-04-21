Extension { #name : 'WeakIdentityKeyDictionary' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
WeakIdentityKeyDictionary >> at: key put: anObject [
	"Set the value at key to be anObject.  If key is not found, create a
	new entry for key and set is value to anObject. Answer anObject."

	| index assoc |
	index := self findElementOrNil: key.
	assoc := self array at: index.
	assoc
		ifNil: [
				self
					atNewIndex: index
					put:
						((WeakKeyAssociation
							  _pretenured_619790590_key: key
							  value: anObject) container: self) ]
		ifNotNil: [ assoc value: anObject ].
	^ anObject
]
