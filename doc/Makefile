ssh_url = auburn@kam.mff.cuni.cz
src_dir = book
target_dir = WWW/eralk

run:
	mdbook serve --open

build:
	mdbook build

deploy:
	mdbook build && rsync -rtu $(src_dir)/* $(ssh_url):$(target_dir)

clean:
	mdbook clean

.PHONY: build run deploy clean
