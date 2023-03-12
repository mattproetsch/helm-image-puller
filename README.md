# Helm image puller

Download Helm chart, scan for images, pull them, and dump to a .tar.gz file.

Great for downloading all the images referenced by a Helm chart and transferring to another computer.

# Usage

```bash
helm-3.6.3/helm repo add bitnami https://charts.bitnami.com/bitnami
./images.sh bitnami/postgresql-ha
```


