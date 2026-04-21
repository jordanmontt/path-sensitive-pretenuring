Extension { #name : 'FM3Element' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
FM3Element class >> named: aString [

	^ self newTenured
		  name: aString;
		  yourself
]
