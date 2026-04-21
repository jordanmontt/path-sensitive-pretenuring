Extension { #name : 'ExternalAddress' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
ExternalAddress >> copyFrom: startIndex to: endIndex [

	| result size |
	size := endIndex - startIndex + 1.
	result := ByteArray newTenured: size.
	LibC memCopy: self + (startIndex - 1) to: result size: size.
	^ result
]
