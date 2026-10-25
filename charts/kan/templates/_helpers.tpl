{{- define "kan.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /*
Truncated at 63 chars for the DNS naming spec; a release name that already contains the chart
name is used as is.
*/}}
{{- define "kan.fullname" -}}
  {{- if .Values.fullnameOverride }}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $name := default .Chart.Name .Values.nameOverride }}
    {{- if contains $name .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "kan.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "kan.labels" -}}
helm.sh/chart: {{ include "kan.chart" . }}
{{ include "kan.selectorLabels" . }}
  {{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "kan.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kan.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "kan.secretName" -}}
  {{- .Values.existingSecret | default (include "kan.fullname" .) }}
{{- end }}

{{- define "kan.image" -}}
  {{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) | trimPrefix "/" }}
{{- end }}

{{- /*
The app and migrate images must move in lockstep (an app newer than its schema 500s on missing
columns), so the migrate image follows the app image unless set explicitly.
*/}}
{{- define "kan.migrateImage" -}}
  {{- $repository := .Values.migrate.image.repository | default (printf "%s-migrate" .Values.image.repository) }}
  {{- $tag := .Values.migrate.image.tag | default .Values.image.tag | default .Chart.AppVersion }}
  {{- printf "%s/%s:%s" .Values.image.registry $repository $tag | trimPrefix "/" }}
{{- end }}
