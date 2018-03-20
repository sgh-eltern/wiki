# CI Tasks

## General Notes

* Base image is in `Dockerfile` and automatically built on [cloud.docker.com](https://cloud.docker.com/app/sghakinternet/repository/docker/sghakinternet/wiki)

* Backup user authenticates with private key:
  - Keys were generated with `ssh-keygen -t rsa -b 4096 -C "backup-pipeline@eltern-sgh.de" -f id_backup-pipeline`
  - Private key added as note to Lastpass entry 'SGH/ssh.strato.de'
  - Public key added to `~/.ssh/authorized_keys` in ssh.strato.de with `ssh-copy-id -i id_backup-pipeline.pub eltern-sgh.de@ssh.strato.de`

## Operating the Pipeline

Copy `sample-credentials.yml` to `credentials.yml` and fill in the values. Do not add this to the repo!

```bash
$ fly login \
    --target your-alias \
    --concourse-url https://ci.example.com/

$ fly set-pipeline \
    --target your-alias \
    --pipeline "SGH Wiki" \
    --config wiki-pipeline.yml \
    --load-vars-from credentials.yml

$ fly unpause-pipeline \
    --target your-alias \
    --pipeline "SGH Wiki"
```

If necessary, the pipeline can be destroyed with:

```bash
fly destroy-pipeline \
    --target your-alias \
    --pipeline "SGH Wiki"
```

## Ghost Schedule

          | Eltern | Wiki | Freunde | GEB
----------|:------:|:----:|:-------:|:---:
Monday    |   x    |   x  |    x    |
Truesday  |   x    |   x  |    x    |  x
Wednesday |   x    |      |    x    |  x
Thursday  |   x    |   x  |         |  x
Friday    |   x    |   x  |    x    |
Saturday  |        |   x  |         |  x
Sunday    |   x    |      |    x    |  x
