# DatingApp V2 - Flutter Project

![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

Um aplicativo de encontros completo desenvolvido com Flutter e Dart, utilizando o Firebase como backend para funcionalidades em tempo real.

## 🚀 Funcionalidades Implementadas

O aplicativo possui um fluxo de usuário robusto e diversas funcionalidades essenciais:

* **📱 Autenticação de Usuários:**
    * Cadastro e Login utilizando E-mail e Senha.
    * Integração completa com o **Firebase Authentication**.
    * Sistema de logout seguro que limpa a pilha de navegação.

* **👤 Gestão de Perfis:**
    * **Criação de Perfil:** Novos usuários são direcionados para uma tela para completar o perfil com informações essenciais.
    * **Edição de Perfil:** Usuários existentes podem acessar e editar suas informações a qualquer momento.
    * **Foto de Perfil:** Permite ao usuário tirar uma foto com a câmera e a salva localmente no dispositivo para persistência.
    * **Dados Salvos:** Nome, sobrenome, data de nascimento, orientação sexual, interesses e foto.

* **❤️ Tela de Matches Dinâmica (`MatchScreen`):**
    * Carrega perfis de usuários diretamente do **Cloud Firestore**.
    * Interface de cards com efeito de empilhamento e animações de swipe (arrastar para os lados).
    * **Sistema de Filtro:** Filtra os perfis exibidos com base na preferência de idade que o usuário salva na tela de configurações.

* **💬 Sistema de Match e Chat em Tempo Real:**
    * **Lógica de "Like":** Ao curtir um perfil, uma sala de chat é criada instantaneamente.
    * **Lista de Conversas:** A tela de chats exibe todas as conversas ativas, carregadas em tempo real do Firestore.
    * **Chat Individual:** Tela de conversa funcional que salva e exibe mensagens em tempo real.
    * **Opções de Interação:** O usuário pode **Remover o Match** ou **Bloquear** (ação fictícia), o que apaga a conversa e o "like" do banco de dados.

* **⚙️ Configurações e Preferências:**
    * **Tela de Configurações:** Menu com acesso a várias funcionalidades, incluindo Logout.
    * **Tela de Preferências:** Permite ao usuário definir a faixa de idade desejada para os matches, salvando essa preferência no Firestore.

* **🔔 Notificações:**
    * Envia uma notificação local quando um "like" é registrado.

## 🛠️ Tecnologias Utilizadas

* **Framework:** [Flutter](https://flutter.dev/)
* **Linguagem:** [Dart](https://dart.dev/)
* **Backend (BaaS):** [Firebase](https://firebase.google.com/)
    * **Firebase Authentication:** Para gestão de usuários.
    * **Cloud Firestore:** Como banco de dados NoSQL em tempo real para perfis, likes, chats e preferências.
* **Principais Pacotes:**
    * `firebase_core`, `firebase_auth`, `cloud_firestore`
    * `image_picker` (para acesso à câmera)
    * `path_provider`, `shared_preferences` (para armazenamento local da foto de perfil)
    * `flutter_local_notifications` (para notificações)

## ⚙️ Configuração do Ambiente

Siga os passos abaixo para rodar o projeto localmente.

### Pré-requisitos

* Ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
* Ter o [Firebase CLI](https://firebase.google.com/docs/cli) instalado e logado.

### 1. Configuração do Firebase
   
1.  Crie um novo projeto no [Firebase Console](https://console.firebase.google.com/).
2.  No seu projeto Firebase, vá para a seção **Authentication** > **Sign-in method** e ative o provedor **"E-mail/senha"**.
3.  Vá para a seção **Cloud Firestore** e clique em **"Criar banco de dados"**. Inicie em **Modo de Teste**.
4.  Vá para a seção **Storage** e clique em **"Primeiros passos"** para ativar o armazenamento de arquivos.
5.  Na raiz do seu projeto Flutter no terminal, rode o comando `flutterfire configure` para conectar seu app ao projeto Firebase. Isso criará o arquivo `lib/firebase_options.dart`.

### 2. Configuração do Projeto Local

```bash
# Clone o repositório
git clone [https://github.com/renanbreier/DatingApp-V2-FlutterProject.git](https://github.com/renanbreier/DatingApp-V2-FlutterProject.git)

# Entre no diretório do projeto
cd DatingApp-V2-FlutterProject

# Instale as dependências
flutter pub get
```

### 3. Executando o App

```bash
# Rode o aplicativo em um emulador ou dispositivo físico
flutter run
```
**Importante:** Ao rodar pela primeira vez, a `MatchScreen` pode apresentar um erro no **Debug Console** pedindo para criar um **índice do Firestore**. Apenas clique no link fornecido no log de erro, crie o índice no console do Firebase e reinicie o app após alguns minutos.

## ✒️ Autores

* **Renan de Oliveira Breier** - [GitHub](https://github.com/renanbreier)
* **Luiza Rodrigues Wenceslau Nanni** - [GitHub](https://github.com/luizananni)
* **Angelo Eduardo Soares Zovaro** - [GitHub](https://github.com/AngeloZovaro)
* **Cauã Barcellos Moreto** - [GitHub](https://github.com/Caua-Moreto)
* **Gustavo de Oliveira Silva** - [GitHub](https://github.com/GustaOSilva)