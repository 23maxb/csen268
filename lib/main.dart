import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

abstract class AuthenticationState {
  const AuthenticationState();
}

class AuthenticationUnauthenticated extends AuthenticationState {
  const AuthenticationUnauthenticated();
}

class AuthenticationAuthenticated extends AuthenticationState {
  final String userToken;

  const AuthenticationAuthenticated(this.userToken);
}

class AuthenticationBloc extends Cubit<AuthenticationState> {
  AuthenticationBloc() : super(const AuthenticationUnauthenticated());

  void logIn(String userId) => emit(AuthenticationAuthenticated(userId));

  void logOut() => emit(const AuthenticationUnauthenticated());
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class Book {
  final String title;
  final String author;
  final String description;
  final String imageUrl;

  const Book({
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
  });
}

enum SortBy { author, title }

class BookState {
  final List<Book> books;
  final SortBy currentSort;
  final Book? selected;

  const BookState({
    this.books = const [],
    this.currentSort = SortBy.author,
    this.selected,
  });

  BookState copyWith({
    List<Book>? books,
    SortBy? currentSort,
    Book? selected,
    bool clearSelected = false,
  }) {
    return BookState(
      books: books ?? this.books,
      currentSort: currentSort ?? this.currentSort,
      selected: clearSelected ? null : (selected ?? this.selected),
    );
  }
}

class BookCubit extends Cubit<BookState> {
  BookCubit() : super(const BookState());

  void init() {
    final books = <Book>[
      const Book(
        title: 'Animal Farm',
        author: 'George Orwell',
        description: 'animal farm desc here',
        imageUrl: 'https://m.media-amazon.com/images/I/81WoYpcR34L.jpg',
      ),
      const Book(
        title: '1984',
        author: 'George Orwell',
        description: '1984 is about dystopia',
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPGF7MjipAwncltcqI-wcWw5iWwYdIGBqt2dZQW2rsKpl3O-cirvx2tZphiXIKs3IUEat1geUbE_z5OOlwrHMiP7EbYFSuCZ8PKDAWctJ2&s=10',
      ),
      const Book(
        title: 'Scythe',
        author: 'Al Shusterman',
        description: 'Really complicated actually',
        imageUrl:
            'https://d28hgpri8am2if.cloudfront.net/book_images/onix/cvr9781442472433/scythe-9781442472433_hr.jpg',
      ),
      const Book(
        title: 'DOAWK',
        author: 'Jeff Kinney',
        description: 'Greg heffley adventures',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/en/8/84/Diary_of_a_Wimpy_Kid_book_cover.jpg',
      ),
    ];
    _sortBooks(books, SortBy.author);
  }

  void sort(SortBy by) => _sortBooks([...state.books], by);

  void _sortBooks(List<Book> books, SortBy by) {
    if (by == SortBy.author) {
      books.sort((a, b) => a.author.compareTo(b.author));
    } else {
      books.sort((a, b) => a.title.compareTo(b.title));
    }
    emit(state.copyWith(books: books, currentSort: by));
  }

  void selectBook(Book book) => emit(state.copyWith(selected: book));

  void clearSelection() => emit(state.copyWith(clearSelected: true));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthenticationBloc>(
      create: (_) => AuthenticationBloc(),
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthenticationBloc>();
          final router = GoRouter(
            initialLocation: '/',
            refreshListenable: GoRouterRefreshStream(authBloc.stream),
            redirect: (context, state) {
              final isAuthed = authBloc.state is AuthenticationAuthenticated;
              final loggingIn = state.matchedLocation == '/login';
              if (!isAuthed) return loggingIn ? null : '/login';
              if (loggingIn) return '/';
              return null;
            },
            routes: [
              GoRoute(
                path: '/login',
                name: 'login',
                builder: (context, state) => const LoginPage(),
              ),
              ShellRoute(
                builder: (context, state, child) => BlocProvider(
                  create: (_) => BookCubit()..init(),
                  child: _ShellScaffold(
                    location: state.matchedLocation,
                    child: child,
                  ),
                ),
                routes: [
                  GoRoute(
                    path: '/',
                    name: 'home',
                    builder: (context, state) => const BookListPage(),
                  ),
                  GoRoute(
                    path: '/byAuthor',
                    name: 'byAuthor',
                    builder: (context, state) =>
                        const BookListPage(sort: SortBy.author),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: 'byAuthorDetail',
                        builder: (context, state) => const BookDetailPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: '/byTitle',
                    name: 'byTitle',
                    builder: (context, state) =>
                        const BookListPage(sort: SortBy.title),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: 'byTitleDetail',
                        builder: (context, state) => const BookDetailPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: '/profile',
                    name: 'profile',
                    builder: (context, state) => const ProfilePage(),
                  ),
                ],
              ),
            ],
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFFF7FA),
                centerTitle: true,
                iconTheme: IconThemeData(color: Colors.black87),
                titleTextStyle: TextStyle(fontSize: 20),
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<AuthenticationBloc>().logIn('user'),
          child: const Text('Log in'),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<AuthenticationBloc>().logOut(),
          child: const Text('Log out'),
        ),
      ),
    );
  }
}

class RootNavigator extends StatelessWidget {
  const RootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookCubit, BookState>(
      builder: (context, state) {
        if (state.selected != null) {
          return BookDetailPage(book: state.selected!);
        }
        return const BookListPage();
      },
    );
  }
}

class BookListPage extends StatelessWidget {
  final SortBy? sort;

  const BookListPage({super.key, this.sort});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<BookCubit, BookState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSortRow(context, state),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
                child: Text("books"),
              ),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.books.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final book = state.books[index];
                    return GestureDetector(
                      onTap: () {
                        context.read<BookCubit>().selectBook(book);
                        final base = sort == SortBy.title
                            ? '/byTitle'
                            : '/byAuthor';
                        context.go('$base/detail');
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(
                          book.imageUrl,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSortRow(BuildContext context, BookState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text("Sort by", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          _SortButton(
            label: "Author",
            isSelected: state.currentSort == SortBy.author,
            onPressed: () => context.read<BookCubit>().sort(SortBy.author),
          ),
          const SizedBox(width: 8),
          _SortButton(
            label: "Title",
            isSelected: state.currentSort == SortBy.title,
            onPressed: () => context.read<BookCubit>().sort(SortBy.title),
          ),
        ],
      ),
    );
  }
}

class BookDetailPage extends StatelessWidget {
  final Book? book;

  const BookDetailPage({super.key, this.book});

  @override
  Widget build(BuildContext context) {
    final book = this.book ?? context.watch<BookCubit>().state.selected;
    if (book == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/byAuthor');
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<BookCubit>().clearSelection(),
        ),
        title: const Text('Book Detail'),
        actions: const [Padding(padding: EdgeInsets.only(right: 12.0))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Center(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.network(
                  book.imageUrl,
                  height: 350,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Author
            Text(
              book.author,
              style: const TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Description
            Text(
              book.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  final Widget child;
  final String location;

  const _ShellScaffold({required this.child, required this.location});

  static const _tabs = [
    ('/byAuthor', Icons.person_outline, 'By Author'),
    ('/byTitle', Icons.text_fields, 'By Title'),
    ('/profile', Icons.settings_outlined, 'Profile'),
  ];

  int get _currentIndex {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF3EDF7),
        selectedItemColor: const Color(0xFF6750A4),
        unselectedItemColor: Colors.black87,
        showUnselectedLabels: true,
        onTap: (i) => context.go(_tabs[i].$1),
        items: [
          for (final t in _tabs)
            BottomNavigationBarItem(icon: Icon(t.$2), label: t.$3),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _SortButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFFE8E0EB)
            : Colors.transparent,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.black87)),
    );
  }
}
