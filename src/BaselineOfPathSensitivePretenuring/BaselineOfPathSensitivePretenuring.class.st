Class {
	#name : 'BaselineOfPathSensitivePretenuring',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPathSensitivePretenuring',
	#package : 'BaselineOfPathSensitivePretenuring'
}

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> baseline: spec [

	<baseline>
	spec for: #common do: [
		"Packages"
		spec package: 'PathSensitivePretenuring'.
		"Pretenured installed methods"
		spec package: 'PathSensitivePretenuring-Cormas-ApplicationMethod'.
		spec package: 'PathSensitivePretenuring-Cormas-LocationOfNew'.
		spec package: 'PathSensitivePretenuring-Cormas-CallerOfNew'.
		""
		spec package: 'PathSensitivePretenuring-DataFrame-ApplicationMethod'.
		spec package: 'PathSensitivePretenuring-DataFrame-LocationOfNew'.
		spec package: 'PathSensitivePretenuring-DataFrame-CallerOfNew'.
		""
		spec package: 'PathSensitivePretenuring-Microdown-ApplicationMethod'.
		spec package: 'PathSensitivePretenuring-Microdown-LocationOfNew'.
		spec package: 'PathSensitivePretenuring-Microdown-CallerOfNew'.
		""
		spec package: 'PathSensitivePretenuring-Moose-ApplicationMethod'.
		spec package: 'PathSensitivePretenuring-Moose-LocationOfNew'.
		spec package: 'PathSensitivePretenuring-Moose-CallerOfNew'.

		"External dependencies"
		spec baseline: 'SendersChainTransformer' with: [ spec repository: 'github://jordanmontt/senders-chain-transformer:main' ].
		spec baseline: 'PretenuringAdviceAlgorithm' with: [ spec repository: 'github://jordanmontt/Pretenuring-Advice-Algorithm:main' ].
		spec baseline: 'VeritasBenchSuite' with: [ spec repository: 'github://jordanmontt/PharoVeritasBenchSuite:main' ].
		"Linking external dependencies"
		spec package: 'PathSensitivePretenuring' with: [ spec requires: #( 'SendersChainTransformer' 'VeritasBenchSuite' 'PretenuringAdviceAlgorithm') ].

		"Groups"
		spec group: 'default' with: #( 'core' ).
		spec group: 'core' with: #( 'PathSensitivePretenuring' ).
		"Pretenured methods group"
		spec group: 'cormas-applicationMethod' with: #( 'core' 'PathSensitivePretenuring-Cormas-ApplicationMethod' ).
		spec group: 'cormas-locationOfNew' with: #( 'core' 'PathSensitivePretenuring-Cormas-LocationOfNew' ).
		spec group: 'cormas-callerOfNew' with: #( 'core' 'PathSensitivePretenuring-Cormas-CallerOfNew' ).
		""
		spec group: 'dataFrame-applicationMethod' with: #( 'core' 'PathSensitivePretenuring-DataFrame-ApplicationMethod' ).
		spec group: 'dataFrame-locationOfNew' with: #( 'core' 'PathSensitivePretenuring-DataFrame-LocationOfNew' ).
		spec group: 'dataFrame-callerOfNew' with: #( 'core' 'PathSensitivePretenuring-DataFrame-CallerOfNew' ).
		""
		spec group: 'microdown-applicationMethod' with: #( 'core' 'PathSensitivePretenuring-Microdown-ApplicationMethod' ).
		spec group: 'microdown-locationOfNew' with: #( 'core' 'PathSensitivePretenuring-Microdown-LocationOfNew' ).
		spec group: 'microdown-callerOfNew' with: #( 'core' 'PathSensitivePretenuring-Microdown-CallerOfNew' ).
		""
		spec group: 'moose-applicationMethod' with: #( 'core' 'PathSensitivePretenuring-Moose-ApplicationMethod' ).
		spec group: 'moose-locationOfNew' with: #( 'core' 'PathSensitivePretenuring-Moose-LocationOfNew' ).
		spec group: 'moose-callerOfNew' with: #( 'core' 'PathSensitivePretenuring-Moose-CallerOfNew' ) ]
]
