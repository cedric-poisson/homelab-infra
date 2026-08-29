# homelab-infra

Infrastructure as Code pour provisionner des ressources Azure via OpenTofu — VM(s) simples et/ou cluster Kubernetes (AKS), avec pipeline CI/CD GitHub Actions.

📝 **[J'ai écrit un post détaillant chaque erreur rencontrée pendant ce projet](https://cedric-poisson.hashnode.dev/every-error-i-hit-deploying-kubernetes-on-azure-with-opentofu-and-what-each-one-taught-me)** — utile si tu veux comprendre les choix, pas juste copier le code.

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
- [x] Pipeline CI/CD (GitHub Actions, plan sur PR + apply automatique sur merge)

## Prérequis pour déployer ce projet

Ce repo est public mais volontairement incomplet : les identifiants et la configuration propre à un environnement ne sont jamais versionnés. Pour déployer depuis un clone, il faut recréer localement :

**Authentification Azure** — un service principal dédié, créé via :
```bash
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription-id>"
```
puis ses identifiants exportés en variables d'environnement (jamais commités) :
```bash
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
```

**Backend distant OpenTofu** — le bloc `backend "azurerm"` dans `versions.tf` pointe vers un storage account précis (`sthomelabtfstate2972`, resource group `rg-tfstate`). Ce storage account n'existe pas par défaut : il faut le créer avant le premier `tofu init`, avec un nom globalement unique sur Azure (donc à adapter dans `versions.tf` si tu redéploies ce repo toi-même) :
```bash
az group create --name rg-tfstate --location swedencentral
az storage account create --name <ton-nom-unique> --resource-group rg-tfstate --sku Standard_LRS
az storage container create --name tfstate --account-name <ton-nom-unique>
```


**Pipeline CI/CD** — si tu utilises la GitHub Action fournie, il faut configurer les secrets `ARM_*` ci-dessus dans Settings > Secrets and variables > Actions du repo, et un token avec la permission `workflow` si tu modifies les fichiers `.github/workflows/` depuis un push.

Sans ces éléments, `tofu apply` échouera proprement en réclamant les valeurs manquantes — comportement attendu.

## Notes / leçons apprises
- **Région** : `francecentral` avait des restrictions de capacité sur les tailles de VM B-series pour cet abonnement étudiant → bascule vers `swedencentral`.
- **Quota** : un abonnement étudiant est limité à 3 IP publiques par région, et à un quota total de vCPU par région (indépendant du quota par famille de VM) — surveiller avec `az vm list-usage --location <region> --output table`.
- **Auth OpenTofu → Azure** : via un service principal dédié (`az ad sp create-for-rbac`), identifiants passés en variables d'environnement `ARM_*`, jamais commités.
- **Cohérence Azure** : le provider `azurerm` peut occasionnellement échouer juste après la création d'une ressource (délai de réplication côté Azure Resource Manager) — se résout avec `tofu import` sur la ressource concernée plutôt qu'en relançant `apply` en boucle.
- **AKS** : le Service CIDR de Kubernetes (réseau virtuel interne, distinct du VNet) doit être défini explicitement pour ne pas chevaucher les plages du VNet ; le node pool système requiert une VM avec plus de 2 cœurs et 4 Go de RAM minimum.
- **Stockage** : arrêter une VM ne stoppe pas la facturation de son disque managé — seule la suppression (`tofu destroy`) le fait.
- **Helm** : chart custom (`helm create`) plutôt que Bitnami, dont le modèle est en transition vers du payant.
- **kubectl/Helm** : un `Service` de type `LoadBalancer` a deux IP distinctes — `CLUSTER-IP` (interne) et `EXTERNAL-IP` (publique, celle à utiliser depuis l'extérieur).
- **État distant (backend)** : nécessaire pour que le pipeline CI/CD et le poste local partagent la même vue de l'infra — stocké dans un Azure Storage Account dédié, séparé de l'infra applicative.
- **GitHub Actions** : un token d'authentification classique nécessite explicitement la permission `workflow` pour pouvoir créer/modifier des fichiers dans `.github/workflows/`.
- **Fichiers locaux dans le code** : éviter les chemins type `~/.ssh/...` dans le code OpenTofu — ils n'existent que sur la machine qui les a créés, pas sur les runners CI/CD éphémères. Préférer un fichier versionné dans le repo (`${path.module}/...`), acceptable pour une clé publique (jamais pour une clé privée).
- **Protection de branche** : sans règle explicite, une PR peut être mergée même si son check CI a échoué — vécu en direct avec une PR mergée malgré un `plan` en échec.

## Roadmap / prochaines pistes
Projets envisagés en suite de celui-ci :
- **Sécurité IaC** : scan automatique du code OpenTofu (`tfsec`/`checkov`) intégré au pipeline CI.
- **Observabilité** : stack Prometheus + Grafana déployée via Helm sur le cluster AKS.
- **GitOps** : migration du déploiement vers ArgoCD ou FluxCD (synchronisation automatique depuis Git plutôt que déploiement déclenché par le pipeline).
- **IA appliquée à l'IaC** : exploration de l'usage de Claude (Anthropic) comme copilote d'analyse — par exemple, revue automatique des `tofu plan` risqués avant `apply` ; exploration du protocole MCP.
