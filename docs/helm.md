# Helm

## Change image tag

````bash
helm pull <helm-repo>/<helm-chart> --version <version> # will download the tar.gz
helm push <helm-chart>-v<version>.tgz oci://<oci-url>/sre/charts 
# this command will push it to /sre/charts/<helm-chart>
```
