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

## Statut
- [x] Compte Azure créé
- [x] Resource group + VNet + subnet (OpenTofu)
- [x] Premier `tofu apply`
- [x] VM de test provisionnée + accès SSH validé
- [ ] Cluster AKS
- [ ] Pipeline CI/CD (GitHub Actions)

## Notes / leçons apprises
- **Région** : `francecentral` avait des restrictions de capacité sur les tailles de VM B-series pour cet abonnement étudiant → bascule vers `swedencentral`.
- **Quota** : un abonnement étudiant est limité à 3 IP publiques par région.
- **Auth OpenTofu → Azure** : via un service principal dédié (`az ad sp create-for-rbac`), identifiants passés en variables d'environnement `ARM_*`, jamais commités.
- **Cohérence Azure** : le provider `azurerm` peut occasionnellement échouer juste après la création d'une ressource (délai de réplication côté Azure Resource Manager) — se résout avec `tofu import` sur la ressource concernée plutôt qu'en relançant `apply` en boucle.