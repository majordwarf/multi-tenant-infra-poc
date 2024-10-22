{{- define "common.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
environment: {{ .Values.global.environment }}
{{- end -}}

{{- define "common.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* PostgreSQL connection string helper */}}
{{- define "postgresql.connectionString" -}}
{{- if eq .Values.postgresql.deployment.mode "dedicated" -}}
postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@{{ .Release.Name }}-{{ .Values.postgresql.deployment.dedicated.name }}:5432/{{ .Values.postgresql.deployment.dedicated.instances.0.database }}
{{- else -}}
postgresql://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@{{ .Values.postgresql.deployment.external.host }}:{{ .Values.postgresql.deployment.external.port }}/{{ .Values.postgresql.deployment.external.database }}
{{- end -}}
{{- end -}}
