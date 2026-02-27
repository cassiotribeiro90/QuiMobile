🍔 Qui Delivery - App de Delivery em Flutter
<div align="center">

https://img.shields.io/badge/Flutter-3.16+-02569B?style=for-the-badge&logo=flutter&logoColor=white
https://img.shields.io/badge/Dart-3.2+-0175C2?style=for-the-badge&logo=dart&logoColor=white
https://img.shields.io/badge/BLoC-8.1+-29B6F6?style=for-the-badge&logo=bloc&logoColor=white
https://img.shields.io/badge/license-MIT-green?style=for-the-badge
<h3>Um aplicativo de delivery completo e moderno, construído com as melhores práticas do Flutter</h3>

https://img.shields.io/badge/demo-coming%2520soon-blue?style=for-the-badge
</div>
📱 Sobre o Projeto

O Qui Delivery é um aplicativo mobile desenvolvido em Flutter que simula uma plataforma completa de delivery de comida. O projeto foi construído com foco em arquitetura limpa, código modular e boas práticas de desenvolvimento, servindo como um excelente portfólio para demonstrar habilidades em Flutter/Dart.
✨ Principais Funcionalidades

    🏪 Catálogo de Lojas - Listagem com filtros por categoria, busca e ordenação

    🍽️ Cardápio Digital - Produtos organizados por seções com imagens e preços

    ⭐ Sistema de Avaliações - Comentários e notas para lojas e produtos

    🛒 Carrinho de Compras - Adição/remoção de itens com cálculo automático

    🗺️ Geolocalização - Distância até as lojas (pronto para API)

    🎨 Interface Moderna - Design inspirado nos principais apps do mercado

🛠️ Tecnologias Utilizadas
Categoria	Tecnologias
Core	Flutter, Dart
Arquitetura	BLoC (Cubit), Repository Pattern, Injeção de Dependência
Navegação	Router personalizado com rotas nomeadas
Estado	flutter_bloc, equatable
HTTP	dio (preparado para API)
Imagens	cached_network_image
Persistência	shared_preferences
Formatação	intl
Assets	JSON mocks para dados locais
📁 Estrutura do Projeto
text

lib/
├── app/
│   ├── assets/
│   │   ├── data/          # Arquivos JSON com dados mock
│   │   └── icon/           # Ícones do app
│   ├── core/
│   │   ├── di/            # Injeção de dependência (GetIt)
│   │   ├── extensions/     # Extensions methods úteis
│   │   ├── utils/          # Helpers e utilitários
│   │   └── constants/      # Constantes e temas
│   ├── data/
│   │   ├── models/         # Modelos de dados
│   │   └── repositories/    # Repositórios (mock + API)
│   ├── modules/
│   │   ├── splash/         # Tela de abertura
│   │   ├── home/           # Tela principal com tabs
│   │   ├── lojas/          # Lista de lojas com filtros
│   │   ├── loja_home/      # Detalhes da loja e cardápio
│   │   ├── loja_avaliacoes/ # Avaliações da loja
│   │   ├── carrinho/       # Carrinho de compras
│   │   └── perfil/         # Perfil do usuário
│   ├── routes/             # Gerenciamento de rotas
│   ├── theme/              # Tema personalizado
│   ├── widgets/            # Widgets reutilizáveis
│   └── shared/             # Código compartilhado
└── main.dart               # Ponto de entrada

🏗️ Arquitetura

O projeto segue os princípios da Clean Architecture com separação clara de responsabilidades:
🔷 Camadas

    Apresentação (UI) - Widgets, telas e componentes visuais

    Lógica de Negócio (BLoC/Cubit) - Gerencia estado e regras de negócio

    Dados (Repository) - Abstrai fonte de dados (mock ou API)

    Modelos - Representação das entidades do domínio

🔷 Fluxo de Dados
text

UI → BLoC → Repository → (Mock/API) → Model → BLoC → UI

🔷 Padrões Utilizados

    Repository Pattern - Abstração da fonte de dados

    Dependency Injection - GetIt para injeção

    BLoC Pattern - Gerenciamento de estado reativo

    Factory Pattern - Para escolher entre mock e API

🚀 Como Executar
Pré-requisitos

    Flutter SDK (versão 3.16 ou superior)

    Dart SDK (versão 3.2 ou superior)

    Android Studio / VS Code

    Emulador ou dispositivo físico

Passos
bash

# Clone o repositório
git clone https://github.com/seu-usuario/qui-delivery.git

# Entre no diretório
cd qui-delivery

# Instale as dependências
flutter pub get

# Execute o app
flutter run

# Para build de release
flutter build apk --release
# ou
flutter build ios --release

🧪 Mocks vs API

O projeto está preparado para funcionar com dados mock (desenvolvimento) ou API real (produção):
dart

// lib/app/core/di/injection.dart
// Em desenvolvimento - usa dados mock
getIt.registerSingleton<LojaRepository>(LojaMockRepository());

// Em produção - usa API real
getIt.registerSingleton<LojaRepository>(
  LojaApiRepository(baseUrl: 'https://api.exemplo.com')
);

// Automático (baseado em debug/production)
getIt.registerSingleton<LojaRepository>(LojaRepositoryFactory.create());

📦 Principais Dependências
yaml

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6      # Gerenciamento de estado
  equatable: ^2.0.5         # Comparação de objetos
  dio: ^5.5.0+1             # Cliente HTTP
  shared_preferences: ^2.2.3 # Armazenamento local
  intl: ^0.19.0             # Formatação de datas/moedas
  cached_network_image: ^3.3.1 # Cache de imagens
  get_it: ^7.6.4            # Injeção de dependência

🎨 Design e UX

    Tema personalizado com cores da marca (#EA1D2C - vermelho delivery)

    Tipografia consistente em todo o app

    Componentes reutilizáveis (cards, botões, listas)

    Feedback visual para ações do usuário

    Skeleton loading para melhor percepção de performance

    Animações sutis para transições

📱 Screenshots
<div align="center"> <table> <tr> <td><img src="screenshots/splash.png" width="200"/></td> <td><img src="screenshots/lojas.png" width="200"/></td> <td><img src="screenshots/loja_home.png" width="200"/></td> </tr> <tr> <td align="center">Splash Screen</td> <td align="center">Lista de Lojas</td> <td align="center">Detalhes da Loja</td> </tr> </table> </div>
🧠 Aprendizados e Desafios
Desafios Superados

    🔄 Migração de GetX para BLoC - Aprendizado sobre gerenciamento de estado mais robusto

    🧩 Arquitetura modular - Organização do código para escalabilidade

    🔌 Preparação para API - Repository pattern para facilitar troca de fontes de dados

    📱 UI responsiva - Adaptação para diferentes tamanhos de tela

Conceitos Aplicados

    Clean Architecture

    SOLID

    DRY (Don't Repeat Yourself)

    Composition over Inheritance

    Single Source of Truth

🗺️ Roadmap
✅ Concluído

    Estrutura inicial do projeto

    Modelos de dados (Loja, Produto, Avaliação)

    Tela de splash com navegação

    Tela principal com BottomNavigationBar

    Lista de lojas com filtros

    Tela de detalhes da loja

    Sistema de avaliações

    Componente de lista com seções

🚧 Em Andamento

    Carrinho de compras

    Checkout e pagamento

    Autenticação de usuários

    Histórico de pedidos

    Modo offline

📅 Futuro

    Notificações push

    Rastreamento em tempo real

    Pagamento com Pix/QR Code

    Chat com entregador

    Modo escuro

🤝 Contribuindo

Contribuições são sempre bem-vindas! Veja como ajudar:

    Fork o projeto

    Crie uma branch (git checkout -b feature/AmazingFeature)

    Commit suas mudanças (git commit -m 'Add some AmazingFeature')

    Push para a branch (git push origin feature/AmazingFeature)

    Abra um Pull Request

📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.
