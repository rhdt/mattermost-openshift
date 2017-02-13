IMAGE = mattermost-team
VERSION = 3.6.2

all: build

build:
	docker build -t $(IMAGE):$(VERSION) mattermost-app

push:
	docker push $(IMAGE):$(VERSION)
