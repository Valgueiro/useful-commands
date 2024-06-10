# K9s

## Add secret as volume

* https://kubernetes.io/docs/concepts/configuration/secret/

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: dotfile-secret
data:
  .secret-file: dmFsdWUtMg0KDQo=
---
apiVersion: v1
kind: Pod
metadata:
  name: secret-dotfiles-pod
spec:
  volumes:
    - name: secret-volume
      secret:
        secretName: dotfile-secret
  containers:
    - name: dotfile-test-container
      image: registry.k8s.io/busybox
      command:
        - ls
        - "-l"
        - "/etc/secret-volume"
      volumeMounts:
        - name: secret-volume
          readOnly: true
          mountPath: "/etc/secret-volume"
```

## Delete evicted pods

````bash
kubectl delete pods  -A --field-selector status.phase=Failed
```

## Remove multiple finalizers

```bash
KIND=
NS=
RESOURCES=$(kubectl get ${KIND} -n $NS --no-headers -o custom-columns=":metadata.name")
for r in $RESOURCES
do
  kubectl patch $KIND $r -n $NS \
    --type json \
    --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'
done
```

