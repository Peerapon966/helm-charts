{{/*
Expand the name of the chart.
*/}}
{{- define "hsr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hsr.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hsr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hsr.labels" -}}
helm.sh/chart: {{ include "hsr.chart" . }}
{{ include "hsr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hsr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hsr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hsr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hsr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the database host URL.
*/}}
{{- define "hsr.dbHost" -}}
{{- if .Values.mysql.useLocal -}}
{{- printf "%s-mysql-0.%s-mysql.%s.svc.cluster.local" (include "hsr.name" .) (include "hsr.name" .) .Values.namespace -}}
{{- else -}}
{{ .Values.mysql.connection.host -}}
{{- end }}
{{- end }}

{{/*
Generate a database connection string using full . context
Usage:
  {{ include "hsr.dbConnectionString" . }}
*/}}
{{- define "hsr.dbConnectionString" -}}
{{- with .Values.mysql.connection }}
{{- printf "mysql://%s:%s@%s:%s/%s" .user .password (include "hsr.dbHost" $) (toString .port) .database -}}
{{- end }}
{{- end }}

{{/*
Generate the redis host URL.
*/}}
{{- define "hsr.redisHost" -}}
{{- if .Values.redis.useLocal -}}
{{- printf "%s-redis-0.%s-redis.%s.svc.cluster.local" (include "hsr.name" .) (include "hsr.name" .) .Values.namespace -}}
{{- else -}}
{{ .Values.redis.connection.host -}}
{{- end }}
{{- end }}

{{/*
Generate a redis connection string using full . context
Usage:
  {{ include "hsr.redisConnectionString" . }}
*/}}
{{- define "hsr.redisConnectionString" -}}
{{- with .Values.redis.connection }}
{{- printf "redis://default:%s@%s:%s" .password (include "hsr.redisHost" $) (toString .port) -}}
{{- end }}
{{- end }}

{{/*
Generate the SMTP host URL.
*/}}
{{- define "hsr.smtpHost" -}}
{{- printf "%s-mailhog-0.%s-mailhog.%s.svc.cluster.local" (include "hsr.name" .) (include "hsr.name" .) .Values.namespace -}}
{{- end }}