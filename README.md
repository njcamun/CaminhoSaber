# Educlass

Aplicativo educacional desenvolvido em Flutter.

## Web

O projeto esta configurado para publicar automaticamente no GitHub Pages a cada push na branch `main`.

Link esperado de publicacao:

- https://njcamun.github.io/CaminhoSaber/

## Login Google na Web

Para os utilizadores entrarem com Google no link acima, e necessario configurar no Firebase Console:

- Authentication > Sign-in method > Google: ativado
- Authentication > Settings > Authorized domains: adicionar `njcamun.github.io`

Sem esse dominio autorizado, o login Google na web pode falhar mesmo com a app publicada.

## Desenvolvimento

Comandos principais:

- `flutter pub get`
- `flutter run`
- `flutter build web --release`
