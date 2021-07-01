# https://github.com/bitnami/charts/blob/master/bitnami/nginx-ingress-controller/values.yaml
resource "kubernetes_namespace" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
  }
}

resource "helm_release" "nginx-ingress" {
  name = "nginx-ingress-controller"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  namespace = "nginx-ingress"

  set {
    name  = "containerSecurityContext.runAsUser"
    value = "101"
  }
  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "image.repository"
    value = "rancher/nginx-ingress-controller"
  }

  set {
    name  = "image.tag"
    value = "nginx-0.47.0-rancher1"
  }

  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.nodePorts.http"
    value = "30080"
  }

  # Check this one
  set {
    name  = "service.ports.http"
    value = "30080"
  }

  set {
    name  = "autoscaling.enabled"
    value = "true"
  }

  set {
    name  = "autoscaling.minReplicas"
    value = "2"
  }

  set {
    name  = "defaultBackend.image.repository"
    value = "arm64v8/nginx"
  }

  set {
    name  = "defaultBackend.enabled"
    value = "false"
  }

  depends_on = [
    null_resource.kubeconfig
  ]
}