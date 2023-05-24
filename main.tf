locals {
  k0s_config = {
    version       = "1.27.1+k0s.0"
    dynamicConfig = true
    config = {
      apiVersion = "k0s.k0sproject.io/v1beta1"
      kind       = "Cluster"
      metadata = {
        name = var.cluster_name
      }
      spec = {
        api = {
          externalAddress = var.fqdn
          k0sApiPort      = 9443
          port            = 6443
          sans = [
            var.fqdn,
          ]
          extraArgs = {
            "service-account-issuer"   = var.service_account_issuer
            "service-account-jwks-uri" = var.service_account_jwks_uri
          }
        }
        installConfig = {
          users = {
            etcdUser          = "etcd"
            kineUser          = "kube-apiserver"
            konnectivityUser  = "konnectivity-server"
            kubeAPIserverUser = "kube-apiserver"
            kubeSchedulerUser = "kube-scheduler"
          }
        }
        konnectivity = {
          adminPort = 8133
          agentPort = 8132
        }
        network = {
          kubeProxy = {
            disabled = false
            mode     = "iptables"
          }
          podCIDR     = "10.244.0.0/16"
          provider    = "custom"
          serviceCIDR = "10.96.0.0/12"
        }
        storage = {
          type = "etcd"
        }
        telemetry = {
          enabled = true
        }
        extensions = {
          helm = {
            repositories = [
              {
                name = "cilium"
                url  = "https://helm.cilium.io/"
              }
            ]
            charts = [
              {
                order     = 1
                name      = "cilium"
                chartname = "cilium/cilium"
                namespace = "kube-system"
                version   = "1.13.2"
                # values    = yamlencode({

                # })
              }
            ]
          }
        }
      }
    }
  }

  k0sctl_config = {
    apiVersion = "k0sctl.k0sproject.io/v1beta1"
    kind       = "Cluster"
    metadata = {
      name = var.cluster_name
    }
    spec = {
      hosts = concat(
        [
          for host in var.controllers : {
            ssh = {
              address = each.value
              user    = var.user
              port    = 22
              keyPath = var.sshkey_path
            }
            role = "controller+worker"
          }
        ],
        [
          for host in var.workers : {
            ssh = {
              address = each.value
              user    = var.user
              port    = 22
              keyPath = var.sshkey_path
            }
            role = "worker"
          }
        ]
      )
      k0s = local.k0s_config
    }
  }
}
