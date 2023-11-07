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
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
Environment: {{ required (printf $requiredMsg "tags.Environment") .Values.tags.Environment | quote }}
ServiceCode: {{ required (printf $requiredMsg "tags.ServiceCode") .Values.tags.ServiceCode | quote }}
ServiceName: {{ required (printf $requiredMsg "tags.ServiceName") .Values.tags.ServiceName | quote }}
ServiceType: {{ .Values.tags.ServiceType | default "Dedicated" }}
Purpose: {{ required (printf $requiredMsg "tags.Purpose") .Values.tags.Purpose | quote }}
ManagedBy: AzureServiceOperator
Restriction: AUTOMATED CHANGES ONLY
kubernetes_cluster: {{ required (printf $requiredMsg "tags.kubernetes_cluster") .Values.tags.kubernetes_cluster | quote }}
kubernetes_namespace: {{ required (printf $requiredMsg "tags.kubernetes_namespace") .Values.namespace | quote }}
kubernetes_label_ServiceCode: {{ required (printf $requiredMsg "tags.kubernetes_label_ServiceCode") .Values.tags.ServiceCode | quote }}
{{- end -}}


{{/*
resource FullName
*/}}
{{- define "resource.fullname" -}}
{{- $ := index . 0 }}
{{- $resourceName := index . 1 }}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
{{- $resourceNamePrefix := (required (printf $requiredMsg "namespace") $.Values.namespace) | lower }}
{{- (printf "%s-%s" $resourceNamePrefix $resourceName) | lower }}
{{- end }}


{{/*
managedidentity Name. Each service will have one managedidentity and it follows standard naming convention which is derived in adp-flux-services
*/}}
{{- define "managedidentity.name" -}}
{{- $requiredMsg := include "adp-aso-helm-library.default-check-required-msg" . }}
{{- $teamMIPrefix := (required (printf $requiredMsg "teamMIPrefix") $.Values.teamMIPrefix) }}
{{- $serviceName := (required (printf $requiredMsg "serviceName") $.Values.serviceName) }}
{{- if (and $teamMIPrefix $serviceName) }}
{{- (printf "%s-%s" $teamMIPrefix $serviceName) | lower }}
{{- else }}
{{- printf "this-condition-is-required-for-linting" }}
{{- end }}
{{- end }}

{{/*
managedidentity ConfigMapName
*/}}
{{- define "managedidentity.configMapName" -}}
{{- printf "%s-mi-identity-settings" (include "managedidentity.name" .) }}
{{- end }}

{{/*
roleDefinitionId for the roleAssignment
*/}}
{{- define "roleAssignment.roleDefinitionId" -}}
{{- $roleName := . | lower }}
{{- if eq $roleName "queuesender" }}
{{- printf (include "builtInRole.azureServiceBusDataSenderId" .) }}
{{- else if eq $roleName "queuereceiver" }}
{{- printf (include "builtInRole.azureServiceBusDataReceiverId" .) }}
{{- else if eq $roleName "topicsender" }}
{{- printf (include "builtInRole.azureServiceBusDataSenderId" .) }}
{{- else if eq $roleName "topicreceiver" }}
{{- printf (include "builtInRole.azureServiceBusDataReceiverId" .) }}
{{- else }}
{{- fail (printf "Value for roleName is not as expected. '%s' role is not in the allowed roles." $roleName) }}
{{- end }}
{{- end }}


{{/*
Scope for the roleAssignment
*/}}
{{- define "roleAssignment.scope" -}}
{{- $ := index . 0 }}
{{- $resourceName := index . 1 }}
{{- $resourceType := index . 2 }}
{{- if eq $resourceType "namespaceQueue" }}
{{- printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.ServiceBus/namespaces/%s/queues/%s" $.Values.subscriptionId $.Values.serviceBusResourceGroupName $.Values.serviceBusNamespaceName $resourceName }}
{{- else if eq $resourceType "namespaceTopic" }}
{{- printf "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.ServiceBus/namespaces/%s/topics/%s" $.Values.subscriptionId $.Values.serviceBusResourceGroupName $.Values.serviceBusNamespaceName $resourceName }}
{{- end }}
{{- end }}
