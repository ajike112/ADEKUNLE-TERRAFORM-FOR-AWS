
###################
## KUBERNETES NAMESPACE FOR MONITORING
###################

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }

    lifecycle {
    ignore_changes = all
  }
}

###################
## NAMESPACE: ARGOCD
###################

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  lifecycle {
    ignore_changes = all
  }
}

###################
## NAMESPACE: CERT-MANAGER
###################

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }

  lifecycle {
    ignore_changes = all
  }
}

###################
## NAMESPACE: TRACING (JAEGER)
###################

resource "kubernetes_namespace" "tracing" {
  metadata {
    name = "tracing"
  }

  lifecycle {
    ignore_changes = all
  }
}

######################
# LOKI NAMESPACE
######################
resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }

  lifecycle {
    ignore_changes = all
  }
}

###################
## HELM RELEASES
###################

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  
  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.alb_ingress
  ]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.alb_ingress
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  depends_on = [
    kubernetes_namespace.argocd,
    helm_release.alb_ingress
  ]
}

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server"
  chart            = "metrics-server"
  namespace        = "kube-system"


  depends_on = [
    helm_release.alb_ingress
  ]
}

###############################
## AWS LOAD BALANCER CONTROLLER
###############################

resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_controller_role_arn
    }
  }
}

resource "helm_release" "alb_ingress" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.region   
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [
    var.eks_node_group_dep,
    kubernetes_service_account.alb_sa,
    var.oidc_provider_dep,
    var.alb_controller_policy_attachment_dep
  ]
}


###################
## CERT MANAGER
###################

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  
  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [
    kubernetes_namespace.cert_manager,
    helm_release.alb_ingress
  ]
}

###################
## LOKI
###################
resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-distributed"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  
  values = [
    file("${path.module}/loki-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.logging,
    helm_release.alb_ingress
  ]
}

###################
## JAEGER
###################

resource "helm_release" "jaeger" {
  name             = "jaeger"
  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger"
  namespace  = kubernetes_namespace.tracing.metadata[0].name

  depends_on = [
     kubernetes_namespace.tracing,
    helm_release.alb_ingress
  ]
}

