Set of configurations to run Mattermost Team on Openshift

## Building the image

    make build

## Running the image

    docker run --name=mattermost-team -it \
        -e MM_DB_HOST=db \
        -e MM_DB_PORT=5432 \
        -e MM_DB_USER=mmdbuser \
        -e MM_DB_PASS=mmdbpass \
        -e MM_DB_NAME=mattermost \
        mattermost-team:3.6.2
