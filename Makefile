IMAGE_VERSION := $(shell ruby -e 'require_relative "lib/libis/tools/version"; puts Libis::Tools::VERSION')

install:
	bundle install

update:
	bundle update

release:
	git commit -am "Version bump: v$(IMAGE_VERSION)" || true
	git tag --force "v$(IMAGE_VERSION)"
	git push --force --tags
	bundle exec rake changelog
	git commit -a -m "Changelog update" || true
	git push --force
