package targets

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#RHEL9: {
	ref: core.#Ref | *"almalinux:9"

	_img: docker.#Pull & {
		source: ref
	}

	_build: #_RpmBase & {
		prefix: "rhel9"
		input:  _img.output
	}
	output: _build.output
}
