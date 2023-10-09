{{/*
A default message string to be used when checking for a required value
*/}}
{{- define "adp-aso-helm-library.default-check-required-msg" -}}
{{- "No value found for '%s' in adp-aso-helm-library template" -}}
{{- end -}}

{{/*
Common Tags for Azure resources
*/}}
{{- define "adp-aso-helm-library.tags" -}}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . -}}
Environment: {{ required (printf $requiredMsg "Environment") .Values.tags.Environment | quote }}
ServiceCode: {{ required (printf $requiredMsg "ServiceCode") .Values.tags.ServiceCode | quote }}
ServiceName: {{ required (printf $requiredMsg "ServiceName") .Values.tags.ServiceName | quote }}
ServiceType: {{ .Values.tags.ServiceType | default "Dedicated" }}
Purpose: {{ required (printf $requiredMsg "Purpose") .Values.tags.Purpose | quote }}
ManagedBy: AzureServiceOperator
Restriction: AUTOMATED CHANGES ONLY
kubernetes_cluster: {{ required (printf $requiredMsg "kubernetes_cluster") .Values.tags.kubernetes_cluster | quote }}
kubernetes_namespace: {{ required (printf $requiredMsg "kubernetes_namespace") .Values.tags.kubernetes_namespace | quote }}
kubernetes_label_ServiceCode: {{ required (printf $requiredMsg "kubernetes_label_ServiceCode") .Values.tags.kubernetes_label_ServiceCode | quote }}
{{- end -}}
