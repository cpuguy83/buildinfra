package targets

import (
	"universe.dagger.io/docker"
	"universe.dagger.io/alpha/debian/apt"
)

#_Debbase: {
	input: docker.#Image

	apt.#Install & {
		packages: {
			"libseccomp-dev": {}
			"go-md2man": {}
		}
	}
}
