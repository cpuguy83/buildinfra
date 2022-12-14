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
		prefix: "bionic"
		input:  _img.output
	}
}
