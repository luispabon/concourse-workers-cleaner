# concourse-workers-cleaner

This image is here to clean Concourse CI workers using https://concourse.ci/fly-prune-worker.html .

This image will be useless when Concourse CI will be able to automatically prune dead workers.

See [kubernetes-cronjob.yaml](kubernetes-cronjob.yaml) for an example on how to set up in kubernetes.

## Configure

| Env var name             | Required | Description                                           |
| ------------------------ | -------- | ----------------------------------------------------- |
| CONCOURSE_URL            | yes      | Concourse URL. Example : https://concourse.foo.io     |
| CONCOURSE_TEAM           | no       | Concourse team name. Default "main"                   |
| CONCOURSE_ADMIN_USERNAME | yes      | Concourse basic auth login for the team               |
| CONCOURSE_ADMIN_PASSWORD | yes      | Concourse basic auth password for the team            |
| CONCOURSE_TARGET         | no       | Concourse target for stalled workers. Default "admin" |
