# Gestion des secrets avec sops et age

Les informations sensibles (comme les mots de passe) ne peuvent pas être définies en clair dans la configuration. Elles sont donc chiffrés par des clés ssh/gpg que seul le propriétaire possède.

## Outils Requis

- Le système hôte doit être NixOS également !

  Ce dépot appelle direnv pour installer les packages nécéssaire à la manipulation des clés et des secrets.

## Initialisation (création du nouvelle clé)

### Étape 1 : Récupérer et convertir la clé publique SSH du serveur

La clé d'hôte SSH du serveur doit être convertie au format age pour pouvoir lui chiffrer des secrets :

```bash
ssh <USER>@<IP_SERVEUR> "cat /etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age

# Résultat attendu : age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

> Alternative manuelle :
> ```bash
> echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." | ssh-to-age
> ```

> Alternative pour utiliser une clé gpg plutôt que ssh :
> Récupérez l'identifiant de votre clé : 
> ```bash
> gpg --list-secret-keys --fingerprint
> ```

### Étape 2 : Configurer `.sops.yaml`

Déclarez les clés autorisées et les règles de chiffrement dans le fichier `.sops.yaml` à la racine du dépôt :

```yaml
creation_rules:
  - path_regex: hosts/server/.*\.yaml$
    key_groups:
      - pgp:
          - "identifiant_cle_gpg"
        age:
          - "age_pc_hote"
          - "age_cle_serveur"
```

### Étape 3 : Créer le fichier de secrets

Créez et chiffrez le fichier de secrets :

```bash
sops hosts/server/secrets.yaml
```

## Opérations courantes & maintenance

### Modifier un fichier chiffré

```bash
sops hosts/server/secrets.yaml
```

### Afficher le contenu en clair (lecture seule)

```bash
sops -d hosts/server/secrets.yaml
```

### Rechiffrer après modification des clés

Si vous ajoutez ou retirez des clés dans `.sops.yaml`, appliquez les changements sur les fichiers existants :

```bash
sops updatekeys hosts/server/secrets.yaml
```

> Pour mettre à jour tous les secrets du dépôt :
> ```bash
> find hosts/ -name "*.yaml" -exec sops updatekeys -y {} \;
> ```

---

## Dépannage : Forcer une clé privée

Si SOPS ne détecte pas automatiquement votre clé privée locale (située par défaut dans `~/.config/sops/age/keys.txt`), passer temporairement la clé privée via variable d'environnement : 

```bash
export SOPS_AGE_KEY="AGE-SECRET-KEY-1..."
sops hosts/server/secrets.yaml
unset SOPS_AGE_KEY
```

> Ou en commande unique (évite d'écrire la clé dans l'historique) : 
> ```bash
> SOPS_AGE_KEY="AGE-SECRET-KEY-1..." sops updatekeys hosts/server/secrets.yaml
> ```