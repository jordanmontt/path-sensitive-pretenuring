Extension { #name : 'ByteString' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
ByteString >> createSymbol [

	^ (ByteSymbol basicNewTenured: self size) string: self
]
