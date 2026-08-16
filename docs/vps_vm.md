# Tester la configuration du vps dans une machine virtuelle (QEMU)

Ce guide explique comment compiler, lancer et réinitialiser localement la configuration NixOS du VPS sous forme de machine virtuelle.

## Prérequis

- Le système hôte doit être NixOS également !

## Construire la VM

Générez le script d'exécution de la VM à partir de la configuration flake :

```bash
nix build .#nixosConfigurations.vps.config.system.build.vm
```

> Le résultat du build crée un lien symbolique `./result` contenant le lanceur QEMU.

Les caractéristiques de la machine virtuelle (capacités matérielles et adresse réseau) sont définies dans le fichier `hosts/server/test_env.nix`.

## Démarrer la VM

Lancez le binaire généré :

```bash
./result/bin/run-vps-vm
```

> Pour lancer la VM en mode terminal sans fenêtre graphique :
> ```bash
> ./result/bin/run-vps-vm -nographic
> ```
>
> Pour quitter QEMU en mode sans graphique : faites `Ctrl + A` puis `X`)

## Première connexion & Mot de passe

À l'initialisation, le mot de passe est `temporaire`. Par sécurité, modifiez le mot de passe utilisateur :

```bash
passwd $USER
```

## Réinitialiser l'état de la VM

QEMU stocke l'état persistant (disque, modifications, base de données) dans un fichier `vps.qcow2` généré dans le répertoire courant.

Pour repartir d'une machine totalement vierge :

> ⚠️ Attention : supprime définitivement toutes les données modifiées dans la VM

```bash
rm -f vps.qcow2
```
