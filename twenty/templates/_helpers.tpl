{{/*
Expand the name of the chart.
*/}}
{{- define "twenty.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "twenty.fullname" -}}
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
{{- define "twenty.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "twenty.labels" -}}
helm.sh/chart: {{ include "twenty.chart" . }}
{{ include "twenty.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "twenty.selectorLabels" -}}
app.kubernetes.io/name: {{ include "twenty.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "twenty.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "twenty.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
    Render 'env' fields.
*/}}
{{- define "twenty.renderEnvValues" -}}
{{- range $k, $v := .Values.twenty.env -}}
{{- if (kindIs "string" $v) }}
- name: {{ $k | quote }}
  value: {{ $v | quote }}
{{- else if (kindIs "map" $v) }}
- name: {{ $k | quote }}
{{- toYaml $v | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
    Render 'env' and 'envFrom' blocks.
*/}}
{{- define "twenty.envBlock" -}}
{{- $isWorker := .isWorker -}}
{{- if or .Values.twenty.envFromConfigMapName .Values.twenty.envFromSecretName }}
envFrom:
  {{- if .Values.twenty.envFromConfigMapName }}
  - configMapRef:
      name: {{ .Values.twenty.envFromConfigMapName }}
  {{- end }}
  {{- if .Values.twenty.envFromSecretName }}
  - secretRef:
      name: {{ .Values.twenty.envFromSecretName }}
  {{- end }}
{{- end }}
env:
  {{- if .Values.ingress.enabled }}
  - name: SERVER_URL
    value: {{ .Values.ingress.host | quote }}
  {{- end }}
  {{- if eq $isWorker "true" }}
  - name: DISABLE_DB_MIGRATIONS
    value: "true"
  {{- end }}
  - name: NODE_PORT
    value: {{ .Values.twenty.port | quote }}
  {{- if .Values.postgresql.enabled }}
  - name: PG_DATABASE_HOST
    value: {{ .Release.Name }}-postgresql
  - name: PG_DATABASE_PASSWORD
    valueFrom: 
      secretKeyRef:
        name: {{ .Release.Name }}-postgresql
        key: postgres-password
  - name: PG_DATABASE_URL
    value: "postgres://postgres:$(PG_DATABASE_PASSWORD)@$(PG_DATABASE_HOST):5432/postgres"
  {{- end }}
  {{- if .Values.redis.enabled }}
  - name: REDIS_URL
    value: "redis://{{ .Release.Name }}-redis-master:6379"
  {{- end }}
  {{- if .Values.minio.enabled }}
  - name: STORAGE_TYPE
    value: "s3"
  - name: STORAGE_S3_REGION
    value: "us-east-1"
  - name: STORAGE_S3_NAME
    value: "twenty"
  - name: STORAGE_S3_ENDPOINT
    value: "{{ .Release.Name }}-minio:9000"
  - name: STORAGE_S3_ACCESS_KEY_ID
    valueFrom: 
      secretKeyRef:
        name: {{ .Release.Name }}-minio
        key: root-user
  - name: STORAGE_S3_SECRET_ACCESS_KEY
    valueFrom: 
      secretKeyRef:
        name: {{ .Release.Name }}-minio
        key: root-password
  {{- end }}
{{- include "twenty.renderEnvValues" . | nindent 2 }}
{{- end -}}