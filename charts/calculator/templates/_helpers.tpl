{{/*
Expand the name of the chart.
*/}}
{{- define "calculator.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncated at 63 chars — Kubernetes naming limit.
*/}}
{{- define "calculator.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "calculator.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "calculator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — used by both the Deployment selector and the Service selector.
Must remain stable across chart upgrades.
*/}}
{{- define "calculator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "calculator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
