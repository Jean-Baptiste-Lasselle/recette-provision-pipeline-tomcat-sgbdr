# Abstract

Recette de provision d'un pipeline serveur Jee / SGBDR.

# Hardware Requirements 

La Machine Virutelle doit avoir les caractéristiques suivantes:

* 2 Go octets de RAM minimum, 4 Go de RAM conseillés
* 1 vCPU, 2 vCPUs conseillés pour une expérience de éveloppement optimale
* 4 cartes réseau dont:
  * 2 doivent être configurées avec un Mode d'accès réseau de type "Bridge Network" ("Accès par pont"), 
  * Et 2 autres doivent être configurées avec un Mode d'accès réseau de type "Internal Network" ("Réseau interne"). Pour l'une de cess cartes, on saisira le nom `RESAU_USINE_LOGICIELLE`, et pour l'autre , le nom `RESEAU_OPS_USINE_LOGIGICIELLE`.

Pour de plus amples détails et explications, cf. `./ModeDemploi.pdf".
  
# Utilisation

Voilà:

```
mkdir provision-pipeline-jee
cd provision-pipeline-jee
git clone "https://github.com/Jean-Baptiste-Lasselle/recette-provision-pipeline-tomcat-sgbdr" .
sudo chmod +x ./monter-cible-deploiement.sh
./monter-cible-deploiement.sh
```