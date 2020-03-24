# Supervision de la plateforme

## Préambule

Cette partie en est à ses balbultiements, toutefois il semble opportun de mentionner les options techniques investiguées.

## Objectif

### Monitoring des performances

Cet aspect est utile pour effectuer un suivi au long cours de l'évolution de la demande en ressources de la solution signaux-faibles, mais également pour réaliser les tests de montée en charge.

### Monitoring de la disponibilité

Ces outils doivent permettre la mise en place de sondes automatiques pour faire remonter des alertes lorsque les dispositifs ne sont plus à même de fournir le service aux utilisateurs.

## Solution envisagée

### netdata

NetData est spécialisé dans la prise d'information sur le fonctionnement du matériel et les indicateurs de performance des services. Il offre par ailleurs une faible emprunte mémoire et cpu ce qui en fait un candidat de choix.

### grafana

Grafana est une solution spécialisée dans l'analyse de série temporelle et la fourniture d'indicateurs au travers de tableaux de bord hautement paramétrables.

### graphite

Graphite permet de collecter les métriques et de les stocker pour une analyse long terme, son intégration avec Grafana et Netdata est une solution relativement répandue et populaire.
