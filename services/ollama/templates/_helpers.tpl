{{- define "ollama.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ollama.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "ollama.name" . -}}
{{- end -}}
{{- end -}}

{{- define "ollama.labels" -}}
app.kubernetes.io/name: {{ include "ollama.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end -}}

{{- define "ollama.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ollama.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
