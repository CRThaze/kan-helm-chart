# kan

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.6.0](https://img.shields.io/badge/AppVersion-0.6.0-informational?style=flat-square)

A Helm chart for deploying Kan, the open source Trello alternative

**Homepage:** <https://kan.bn>

## Source Code

* <https://github.com/CRThaze/kan-helm-chart>
* <https://github.com/kanbn/kan>

### Installing

```console
helm install kan oci://ghcr.io/crthaze/charts/kan \
  --set baseUrl=https://kan.example.com \
  --set auth.secret="$(openssl rand -hex 32)" \
  --set database.url=postgresql://kan:password@postgres:5432/kan
```

### Database and migrations

Kan needs an external PostgreSQL database; the chart does not bundle one. The `kan-migrate`
image runs as an init container on every rollout, so the schema always matches the app image.
The migrations create the `uuid-ossp` and `pg_trgm` extensions, which the database owner can
create without superuser.

### Running a fork

Upstream's workflow publishes the migrate image beside the app image as
`<repository>-migrate`, and a fork running that workflow does the same, so setting
`image.repository` and `image.tag` moves both images.

### Parameters

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| auth.secret | string | `""` | `BETTER_AUTH_SECRET`, a random string of 32+ characters. Changing it signs every user out. |
| baseUrl | string | `""` | Public URL browsers use to reach Kan (`NEXT_PUBLIC_BASE_URL`). Required: auth callbacks and trusted origins are checked against it. |
| database.url | string | `""` | `POSTGRES_URL`, e.g. `postgresql://kan:password@postgres:5432/kan`. Required: unset, Kan falls back to an in-container PGlite database that is lost on restart. |
| env | list | `[]` | Extra container env: SMTP, S3, OAuth/OIDC and the `NEXT_PUBLIC_*` toggles. Every variable is listed in https://github.com/kanbn/kan/blob/main/.env.example |
| envFrom | list | `[]` | Extra container envFrom sources, e.g. a Secret with S3 or OAuth credentials. |
| existingSecret | string | `""` | Existing Secret holding the `BETTER_AUTH_SECRET` and `POSTGRES_URL` keys. When set, the chart creates no Secret and ignores `auth.secret` and `database.url`. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Image Pull Policy, shared by the app and migrate images. |
| image.registry | string | `"ghcr.io"` | Image Registry, shared by the app and migrate images (empty uses the runtime's default, Docker Hub). |
| image.repository | string | `"kanbn/kan"` | App image repository. |
| image.tag | string | Uses `.Chart.appVersion` | App image tag; may pin a digest (`0.6.0@sha256:...`). |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` | Ingress class name. |
| ingress.enabled | bool | `false` | Whether to use an Ingress for application access. |
| ingress.hosts | list | The host of `baseUrl` | Hostnames routed to Kan; Kan serves only from `/`, so each host gets one `/` Prefix path. |
| ingress.tls | list | `[]` |  |
| livenessProbe | object | `{"tcpSocket":{"port":"http"}}` | TCP only, so a database outage does not restart the pod. |
| migrate.image.repository | string | `<image.repository>-migrate` | Migrate image repository. Upstream's workflow publishes it beside the app image with a `-migrate` suffix, so a fork's build follows `image.repository` without setting this. |
| migrate.image.tag | string | `image.tag` | Migrate image tag. The schema must match the app, so it follows `image.tag`; set it explicitly when `image.tag` pins a digest, since a digest belongs to one image. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context. `runAsUser` matters for the migrate image (`node:alpine`), which would otherwise run as root; the app image already runs as 1000. |
| readinessProbe | object | `{"httpGet":{"path":"/api/v1/health","port":"http"},"timeoutSeconds":5}` | `/api/v1/health` answers 200 even when its database check fails, so this proves only that the server responds. |
| replicaCount | int | `1` | Number of replicas. Without `REDIS_URL` in `env`, rate limiting is counted per pod. |
| resources | object | `{}` | Resources for the app and migrate containers. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | Container security context for the app and migrate containers. The root filesystem stays writable: at startup the app writes `public/__ENV.js` with the runtime `NEXT_PUBLIC_*` values. |
| service.port | int | `80` | Service Port. |
| service.type | string | `"ClusterIP"` | Service Type. |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
