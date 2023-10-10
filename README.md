#  ADP Platform Azure Service Operator Helm Library Chart
A Helm chart library that captures general configuration for Azure Service Operator (ASO) resources. It can be used by any microservice Helm chart to import AzureServiceOperator K8s object templates configured to run on the ADP platform.


## Including the library chart

In your microservice Helm chart:
  * Update `Chart.yaml` to `apiVersion: v2`.
  * Add the library chart under `dependencies` and choose the version you want (example below). Version number can include `~` or `^` to pick up latest PATCH and MINOR versions respectively.
  * Issue the following commands to add the repo that contains the library chart, update the repo, then update dependencies in your Helm chart:

```
helm repo add adp https://raw.githubusercontent.com/defra/adp-aso-helm-repository/main/
helm repo update
helm dependency update <helm_chart_location>
```

An example Demo microservice `Chart.yaml`:

```
apiVersion: v2
description: A Helm chart to deploy a microservice to the ADP Kubernetes platform
name: demo-microservice
version: 1.0.0
dependencies:
- name: adp-aso-helm-library
  version: ^1.0.0
  repository: https://raw.githubusercontent.com/defra/adp-aso-helm-repository/master/
```

NOTE: We will use ACR where ASO Helm Library Chart can be published. So above dependencies will be changed to import library from ACR (In Progress).

## Using the K8s object templates

First, follow [the instructions](#including-the-library-chart) for including the ASO Helm library chart.

The ASO Helm library chart has been configured using the conventions described in the [Helm library chart documentation](https://helm.sh/docs/topics/library_charts/). The K8s object templates provide settings shared by all objects of that type, which can be augmented with extra settings from the parent (Demo microservice) chart. The library object templates will merge the library and parent templates. In the case where settings are defined in both the library and parent chart, the parent chart settings will take precedence, so library chart settings can be overridden. The library object templates will expect values to be set in the parent `.values.yaml`. Any required values (defined for each template below) that are not provided will result in an error message when processing the template (`helm install`, `helm upgrade`, `helm template`).

The general strategy for using one of the library templates in the parent microservice Helm chart is to create a template for the K8s object formateted as so:

```
{{- include "adp-aso-helm-library.namespacesqueue" (list . "adp-microservice.namespacesqueue") -}}
{{- define "adp-microservice.namespacesqueue" -}}
# Microservice specific configuration in here
{{- end -}}
```

### All template required values

All the K8s object templates in the library require the following values to be set in the parent microservice Helm chart's `values.yaml`:

```
name: <string>
namespace: <string>

tags:
  Environment: <string>
  ServiceCode: <string>
  ServiceName: <string>
  ServiceType: <string> (Shared or Dedicated)
  Purpose: <string>
  kubernetes_cluster: <string>
  kubernetes_namespace: <string>
  kubernetes_label_ServiceCode: <string>
```

### NameSpaceQueue

* Template file: `_namespacesqueue.yaml`
* Template name: `adp-aso-helm-library.namespacesqueue`

An ASO `namespacesqueue` object to create a Microsoft.ServiceBus/namespaces/queues resource.

A basic usage of this object template would involve the creation of `templates/namespacesqueue.yaml` in the parent Helm chart (e.g. `adp-microservice`) containing:

```
{{- include "adp-aso-helm-library.namespacesqueue" . -}}

```

#### Required values

The following values need to be set in the parent chart's `values.yaml` in addition to the globally required values [listed above](#all-template-required-values).

Note that `namespaceQueues` is array of objects which is used to create more that one queue.

```
serviceBusResourceGroupName: <string>
serviceBusNamespaceName: <string>
namespaceQueues:      
  - name: <string>    
  - name: <string>
```

#### Optional values

The following values can optionally be set in the parent chart's `values.yaml` to set the other properties for servicebus queues:

```
namespaceQueues:
  - name: <string>
    deadLetteringOnMessageExpiration: <bool>           --Default false
    defaultMessageTimeToLive: <string>                 --Default P14D
    duplicateDetectionHistoryTimeWindow: <string>      --Default PT10M
    enableBatchedOperations: <bool>                    --Default true
    enableExpress: <bool>                              --Default false
    enablePartitioning: <bool>                         --Default false
    lockDuration: <string>                             --Default PT1M
    maxDeliveryCount: <int>                            --Default 10
    maxMessageSizeInKilobytes: <int>                   --Default 1024
    maxSizeInMegabytes: <int>                          --Default 1024
    requiresDuplicateDetection: <bool>                 --Default false
    requiresSession: <bool>                            --Default false
```

### PostgresDatabase
    In Progress

### Storage
    In Progress


## Helper templates

In addition to the K8s object templates described above, a number of helper templates are defined in `_helpers.tpl` that are both used within the library chart and available to use within a consuming parent chart.

### Default check required message

* Template name: `adp-aso-helm-library.default-check-required-msg`
* Usage: `{{- include "adp-aso-helm-library.default-check-required-msg" . }}`

A template defining the default message to print when checking for a required value within the library. This is not designed to be used outside of the library.

### Tags

* Template name: `adp-aso-helm-library.tags`
* Usage: `{{- include "adp-aso-helm-library.tags" $ | nindent 4 }}` (`$` is mapped to the root scope)

Common tags to apply to `tags` of all ASO resource objects on the ADP K8s platform. This template relies on the globally required values [listed above](#all-template-required-values).

### Labels 
    In Progress

### Annotation 
    In Progress

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3

The following attribution statement MUST be cited in your products and applications when using this information.

>Contains public sector information licensed under the Open Government license v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable information providers in the public sector to license the use and re-use of their information under a common open licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.

