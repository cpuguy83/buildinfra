package targets

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#Bionic: {
	ref: core.#Ref | *"buildpack-deps:bionic"

	_img: docker.#Pull & {
		source: ref
	}

	#_Debbase & {
		input: _img.output
	}
}
