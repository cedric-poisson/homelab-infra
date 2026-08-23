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
- [x] Cluster AKS provisionné (OpenTofu) + connexion `kubectl` validée
- [x] Déploiement d'une app via Helm (nginx, chart custom)
- [ ] Pipeline CI/CD (GitHub Actions)

## Notes / leçons apprises
- **Région** : `francecentral` avait des restrictions de capacité sur les tailles de VM B-series pour cet abonnement étudiant → bascule vers `swedencentral`.
- **Quota** : un abonnement étudiant est limité à 3 IP publiques par région, et à un quota total de vCPU par région (indépendant du quota par famille de VM) — surveiller avec `az vm list-usage --location <region> --output table`.
- **Auth OpenTofu → Azure** : via un service principal dédié (`az ad sp create-for-rbac`), identifiants passés en variables d'environnement `ARM_*`, jamais commités.
- **Cohérence Azure** : le provider `azurerm` peut occasionnellement échouer juste après la création d'une ressource (délai de réplication côté Azure Resource Manager) — se résout avec `tofu import` sur la ressource concernée plutôt qu'en relançant `apply` en boucle.
- **AKS** : le Service CIDR de Kubernetes (réseau virtuel interne, distinct du VNet) doit être défini explicitement pour ne pas chevaucher les plages du VNet ; le node pool système requiert une VM avec plus de 2 cœurs et 4 Go de RAM minimum.
- **Stockage** : arrêter une VM ne stoppe pas la facturation de son disque managé — seule la suppression (`tofu destroy`) le fait.
- **Helm** : chart custom (`helm create`) plutôt que Bitnami, dont le modèle est en transition vers du payant (images/charts gratuits en fin de maintenance).
- **kubectl/Helm** : un `Service` de type `LoadBalancer` a deux IP distinctes — `CLUSTER-IP` (interne, plage du Service CIDR) et `EXTERNAL-IP` (publique, celle à utiliser depuis l'extérieur).