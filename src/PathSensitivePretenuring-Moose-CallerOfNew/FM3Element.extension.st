Extension { #name : 'FM3Element' }

{ #category : '*PathSensitivePretenuring-Moose-CallerOfNew' }
FM3Element class >> named: aString [

	^ self newTenured
		  name: aString;
		  yourself
]
