# Ajouter un parser dans dbmongo

L'ajout d'un parser permet d'intégrer de nouveaux types de fichiers dans le modèle de données de dbmongo.

## Structure du parser
Un parser est une fonction du type 
```go
func (cache marshal.Cache, batch *base.AdminBatch) (chan marshal.Tuple, chan marshal.Event)
```

Le channel `marshal.Tuple` achemine les données collectées par le parser.
Le channel `marshal.Event` quand à lui achemine les messages du parser qui seront insérés dans la collection `Journal`.

Il est conseillé de dédier un module golang pour chaque type de données, il est toutefois possible de cumuler plusieurs parsers au sein du même module lorsque cela présente des avantage de factorisation du code.

## Type de données
Le type marshal.Tuple peut contenir n'importe quelles données, toutefois il faut veiller à ce que les tags `json` et `bson` du type soient alignés de façon à mener des tests concluants.

Cette interface exige 3 fonctions qui fournissent les données d'identification de l'objet dans la base de données:
```go
type Tuple interface {
	Key() string      // id de l'objet
	Scope() string    // "etablissement" ou "entreprise"
	Type() string     // clé sous laquelle on retrouve les données dans RawData
}
```

## Tests
Des outils sont disponibles pour réaliser facilement des tests et intégrer les fonctionnalités de la suite de test du repository opensignauxfaibles:

Exemple:
```golang
package ellisphere

import (
	"flag"
	"path/filepath"
	"testing"

	"github.com/signaux-faibles/opensignauxfaibles/dbmongo/lib/marshal"
)

var update = flag.Bool("update", false, "Update the expected test values in golden file")

func TestApdemande(t *testing.T) {
	var golden = filepath.Join("testData", "expectedEllisphere.json")
	var testData = filepath.Join("testData", "ellisphereTestData.excel")
	marshal.TestParserTupleOutput(t, Parser, marshal.NewCache(), "ellisphere", testData, golden, *update)
}
```

Dans le cas présenté ci-dessus, il faut disposer les fichiers dans un répertoire testData à l'intérieur du module.
Ces tests sont utilisables par le biais de go test, ou de /test-all.sh.

## Inscription du parser
Afin de rendre le parser disponible dans l'instance dbmongo, il faut l'enregistrer dans la variable `registeredParsers` du fichier handlers.go.

Le nouveau parser sera sollicité lorsqu'une ressource est décrite dans un objet `AdminBatch` avec le type cité dans l'enregistrement.