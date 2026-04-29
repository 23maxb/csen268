import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF7FA),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Color(0xFF333333), fontSize: 20),
        ),
      ),
      home: BlocProvider(
        create: (_) => BookCubit()..init(),
        child: const RootNavigator(),
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
  const BookListPage({super.key});

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
                      onTap: () => context.read<BookCubit>().selectBook(book),
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
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
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
