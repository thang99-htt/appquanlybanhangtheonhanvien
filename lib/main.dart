import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'models/product.dart';
import 'ui/home_screen.dart';
import 'ui/notifications/notifications_manager.dart';
import 'ui/products/salesinfo_manager.dart';
import 'ui/screens.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => AuthManager(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => ProductsManager(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => UsersManager(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => OrdersManager(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => NotificationsManager(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => SalesInfoManager(),
          ),
        ],
        child: Consumer<AuthManager>(
          builder: (ctx, authManager, child) {
            return MaterialApp(
              title: 'Katec',
              theme: ThemeData(
                scaffoldBackgroundColor: Colors.white,
                fontFamily: 'Lato',
              ),
              home: authManager.isAuth
                  ? const HomeScreen()
                  : FutureBuilder(
                      future: authManager.tryAutoLogin(),
                      builder: (ctx, snapshot) {
                        return snapshot.connectionState ==
                                ConnectionState.waiting
                            ? const SplashScreen()
                            : const AuthScreen();
                      },
                    ),
              // home: const HomeScreen(),
              routes: {
                ProductsOverviewScreen.routeName: (ctx) =>
                    const ProductsOverviewScreen(),
                ManagerProductsScreen.routeName: (ctx) =>
                    const ManagerProductsScreen(),
                ManagerUsersScreen.routeName: (ctx) =>
                    const ManagerUsersScreen(),
                ManagerOrdersScreen.routeName: (ctx) =>
                    const ManagerOrdersScreen(),
                ManagerRevenuesScreen.routeName: (ctx) =>
                    ManagerRevenuesScreen(),
              },
              onGenerateRoute: (settings) {
                if (settings.name == EditProductScreen.routeName) {
                  final productId = settings.arguments as int?;
                  return MaterialPageRoute(
                    builder: (ctx) {
                      return EditProductScreen(
                        product: productId != null
                            ? ctx.read<ProductsManager>().findById(productId)
                            : null,
                      );
                    },
                  );
                }
                if (settings.name == EditUserScreen.routeName) {
                  final userId = settings.arguments as int?;
                  return MaterialPageRoute(
                    builder: (ctx) {
                      return EditUserScreen(
                        user: userId != null
                            ? ctx.read<UsersManager>().findById(userId)
                            : null,
                      );
                    },
                  );
                }

                if (settings.name == AddOrderScreen.routeName) {
                  return MaterialPageRoute(
                    builder: (ctx) {
                      return const AddOrderScreen();
                    },
                  );
                }

                if (settings.name == UserAddOrderScreen.routeName) {
                  final product = settings.arguments as Product;
                  return MaterialPageRoute(
                    builder: (ctx) {
                      return UserAddOrderScreen(product: product);
                    },
                  );
                }

                return null;
              },
            );
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
