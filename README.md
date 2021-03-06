# AppStoreRatings
AppStoreRatings es una librería para gestionar automáticamente cuándo pedir al usuario que deje una valoración en AppStore.

## Instalación con CocoaPods

[CocoaPods](http://cocoapods.org) es un gestor de dependencias para proyectos en Cocoa. Para más información sobre su uso e instalación visite su sito web.
Para integrar AppStoreRatings en un proyecto Xcode, especifique en el `Podfile`:

```
pod 'AppStoreRatings', :git => 'https://github.com/AjuntamentdeBarcelona/osam-valoracions-ios', :tag => '1.0.1'
```



## Configuración
AppStoreRatings utiliza un archivo de configuración en formato JSON para indicar cuándo se debe mostrar al usuario el mensaje de valoración.

Es necesario indicar en el fichero `config_keys.plist` en la variable `rate_url` la url donde está el json que tiene las condiciones de valoracion.

Ejemplo de una archivo JSON de configuración:

```
     {
        "tmin" : 0,
        "num_apert" : 1
     }
```

El parámetro "tmin" indica el mínimo número de días que deben transcurrir desde la primera vez que se inicia la app.

El parámetro "num_apert" indica cuántas veces como mínimo de debe haber iniciado la app.

Si se cumplen estos dos requisitos, la librería llamará automáticamente al `SKStoreReviewController.requestReview()` para mostrar el mensaje estandar del sistema para pedir una valoración.

Una vez que se ha pedido la valoración no se volverá a mostrar a menos que se realice una actualización de la app. En cuanto cambie el build number de la app (`CFBundleVersion`) se reiniciará la cuenta del número de días y número de inicios necesarios para mostrar el mensaje de valoración.

*Nota: existe una limitación de iOS por la cual el mensaje de valoración se mostrará como máximo 3 veces en un período de 365 días, para evitar que se vuelva muy repetitivo para el usuario.*



## Uso

Cada vez que se inicie la app se debe llamar a la función de actualización de estado.
Si se cumplen las condiciones indicadas en el archivo de configuración se mostará el mensaje de valoración.

### Actualizar estado

La forma más sencilla es usar esta función::

```
AppStoreRatings.shared.updateRatingStats(configURL: url)
```


Se puede obtener información sobre si el mensaje de valoración se ha mostrado o se ha producido algún error:

```
AppStoreRatings.shared.updateRatingStats(configURL: url) { result in
            switch result {
            case .success(let isDialogRequested):
                NSLog("Finished: isDialogRequested: \(isDialogRequested)")
                
            case .failure(let error):
                NSLog("error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
```


### Información sobre el estado actual

Para facilitar el testeo de apps que usen esta librería se incluyen dos funciones que facilitan ver cuál es el valor de las variables internas y qué condiciones faltan por cumplir para mostrar el mensaje de valoración.

**Descripción de la variables internas:**

```
let statusDescription = AppStoreRatings.shared.currentStatusDescription()
```

El resultado es un mensaje como este: `launchCount: 3, firstLaunch: 2/8/19, wasPreviouslyRequested: false`


**Información más detallada:** 
La función `debugCurrentStatus` devuelve varias variables con el número de días e inicios que faltan para mostrar el mensaje, etc...

```
AppStoreRatings.shared.debugCurrentStatus(configURL: url) { result in
            switch result {
            
            case let .success(isDialogRequested, launchCountsRemaining, daysRemaining, wasPreviouslyRequested):
                NSLog("isDialogRequested: \(isDialogRequested)")
                NSLog("wasPreviouslyRequested: \(wasPreviouslyRequested)")
                NSLog("launchCountsRemaining: \(launchCountsRemaining)")
                NSLog("daysRemaining: \(String(format: "%.3f", daysRemaining))")

            case .failure(let error):
                NSLog("error: \(error.localizedDescription)")
            }
        }

```

### Uso desde Objective-C
Para usar la librería desde Objective-C se proporcionan funciones equivalentes sin el uso de enumeraciones para el resultado.

**Uso básico:**

```
[AppStoreRatings.shared updateRatingStatsWithConfigUrl:url completion:nil];

```

**Uso con resultado:**

```
    [AppStoreRatings.shared updateRatingStatsWithConfigUrl:url completion:^(BOOL isDialogRequested, NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"Finished: isDialogRequested %@", isDialogRequested ? @"yes":@"no");
        }
        else {
            NSLog(@"error %@", error.localizedDescription);
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
```

**Información de estado interno:**
```
NSString* statusDescription = AppStoreRatings.shared.currentStatusDescription()
```

**Información detallada de estado interno:**

```
[AppStoreRatings.shared debugCurrentStatusWithConfigURL:url completion:^(BOOL isDialogRequested, NSInteger launchCountsRemaining, double daysRemaining, BOOL wasPreviouslyRequested, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error %@", error.localizedDescription);
        }
        else {
            NSLog(@"isDialogRequested %@", isDialogRequested ? @"yes":@"no");
            NSLog(@"wasPreviouslyRequested %@", wasPreviouslyRequested ? @"yes":@"no");
            NSLog(@"launchCountsRemaining %ld",launchCountsRemaining);
            NSLog(@"daysRemaining %@", [NSString stringWithFormat:@"%.3f", daysRemaining] );
        }
    }];
```


## Ejemplos de uso
En el directorio `Examples` se incluye un ejemplo de uso:

- **Test_Swift**: ejemplo de uso desde un proyecto en Swift
- **Test_ObjectiveC**: ejemplo de uso desde un proyecto en Objective-C


## Licencia de uso

Copyright (C) 2019 Ajuntament de Barcelona

AppStoreRatings se publica bajo licencia BSD. Ver el archivo [LICENSE](https://gitlab.dtibcn.cat/osam_pm/modul_valoracions_ios/LICENSE) para más detalles.

