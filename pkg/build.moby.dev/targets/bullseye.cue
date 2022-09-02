package targets

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#Bullseye: {
	ref: core.#Ref | *"buildpack-deps:bullseye"

	_img: docker.#Pull & {
		source: ref
	}

	_build: #_Debbase & {
		prefix: "bullseye"
		input:  _img.output
	}
	output: _build.output
}
