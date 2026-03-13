{{/*
Expand the name of the chart.
*/}}
{{- define "tridentprotect.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tridentprotect.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tridentprotect.labels" -}}
helm.sh/chart: {{ include "tridentprotect.chart" . }}
{{ include "tridentprotect.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.customLabels }}
{{ toYaml .Values.customLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tridentprotect.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tridentprotect.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{/*
Create full path to Controller Image
*/}}
{{- define "tridentprotect.fullImage" -}}
{{- $registry := "" }}
{{- if and (hasKey .Values.controller.image "registry") (not (eq .Values.controller.image.registry nil)) }}
  {{- $registry = .Values.controller.image.registry }}
{{- else }}
  {{- $registry = .Values.imageRegistry }}
{{- end }}
{{- if $registry }}
  {{- if hasSuffix "/" $registry }}
    {{- printf "%s%s" $registry .Values.controller.image.repository -}}
  {{- else -}}
    {{- printf "%s/%s" $registry .Values.controller.image.repository -}}
  {{- end -}}
{{- else -}}
  {{ .Values.controller.image.repository -}}
{{- end -}}
:{{ .Values.controller.image.tag | default .Chart.AppVersion }}
{{- end -}}

{{/*
Create full path to webhooksCleanup Image
*/}}
{{- define "tridentprotect.webhooksCleanupImage" -}}
{{- $registry := "" }}
{{- if and (hasKey .Values.webhooksCleanup.image "registry") (not (eq .Values.webhooksCleanup.image.registry nil)) }}
  {{- $registry = .Values.webhooksCleanup.image.registry }}
{{- else }}
  {{- $registry = .Values.imageRegistry }}
{{- end }}
{{- if $registry }}
  {{- if hasSuffix "/" $registry }}
    {{- printf "%s%s" $registry .Values.webhooksCleanup.image.repository -}}
  {{- else -}}
    {{- printf "%s/%s" $registry .Values.webhooksCleanup.image.repository -}}
  {{- end -}}
{{- else -}}
  {{ .Values.webhooksCleanup.image.repository -}}
{{- end -}}
:{{ .Values.webhooksCleanup.image.tag }}
{{- end -}}

{{/*
Create full path to crCleanup Image
*/}}
{{- define "tridentprotect.crCleanupImage" -}}
{{- $registry := "" }}
{{- if and (hasKey .Values.crCleanup.image "registry") (not (eq .Values.crCleanup.image.registry nil)) }}
  {{- $registry = .Values.crCleanup.image.registry }}
{{- else }}
  {{- $registry = .Values.imageRegistry }}
{{- end }}
{{- if $registry }}
  {{- if hasSuffix "/" $registry }}
    {{- printf "%s%s" $registry .Values.crCleanup.image.repository -}}
  {{- else -}}
    {{- printf "%s/%s" $registry .Values.crCleanup.image.repository -}}
  {{- end -}}
{{- else -}}
  {{ .Values.crCleanup.image.repository -}}
{{- end -}}
:{{ .Values.crCleanup.image.tag }}
{{- end -}}

{{/*
Generate certificates for tridentprotect API server
*/}}
{{- define "tridentprotect.gen-certs" -}}
{{- $expire := 1825 }} # 5 years
{{- $ca := genCA .Values.webhook.serviceName $expire }}
{{- $webhookdomain1 := printf "%s.%s.svc" .Values.webhook.serviceName $.Release.Namespace }}
{{- $webhookdomain2 := printf "%s.%s.svc.cluster.local" .Values.webhook.serviceName $.Release.Namespace }}
{{- $metricsdomain := printf "%s-controller-manager-metrics-service" .Values.namePrefix }}

{{- $domains := list $webhookdomain1 $webhookdomain2 $metricsdomain }}
{{- $cert := genSignedCert .Values.webhook.serviceName nil $domains $expire $ca }}
caCert: {{ $ca.Cert | b64enc }}
clientCert: {{ $cert.Cert | b64enc }}
clientKey: {{ $cert.Key | b64enc }}
{{- end }}

{{/*
Get the CA cert from the secret and concat with the new cert to allow for multiple certs in the bundle
This ensures that the admission webhook holds both certs and can be used for verification of overlapping pods
during upgrade operations.
*/}}
{{- define "tridentprotect.gen-ca-bundle" -}}
{{- $newCert := index . 0 -}}
{{- $context := index . 1 -}}
{{- $secret := (lookup "v1" "Secret" $context.Release.Namespace $context.Values.webhook.tlsSecretName) -}}
{{- if $secret.data -}}
{{- $oldCert := index $secret.data "ca.crt" -}}
{{- $oldCertDec := b64dec $oldCert -}}
{{- $newCertDec := b64dec $newCert -}}
{{- $bundle := (printf "%s%s" $newCertDec $oldCertDec) | b64enc -}}
{{- $bundle -}}
{{- else -}}
{{- $newCert -}}
{{- end -}}
{{- end -}}
