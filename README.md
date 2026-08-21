# homelab-infra

Infrastructure as Code pour provisionner des ressources Azure via OpenTofu — VM(s) simples et/ou cluster Kubernetes (AKS), avec pipeline CI/CD GitHub Actions.

## Objectif
Automatiser le provisionnement d'une infrastructure Azure reproductible, en partant d'une VM simple et en montant en complexité vers un cluster Kubernetes managé selon le budget/crédit disponible (compte étudiant Azure).

## Stack
- OpenTofu (provider azurerm)
- VM(s) Azure et/ou Azure Kubernetes Service (AKS)
- Helm (si AKS)
- GitHub Actions (CI/CD)

## Note coût
Le control plane AKS est gratuit ; les coûts viennent des VMs (node pools), du stockage et du réseau.
Réflexe : `tofu destroy` après chaque session de travail pour ne pas laisser tourner les ressources inutilement.
