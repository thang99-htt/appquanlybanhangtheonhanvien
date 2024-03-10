import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'ui/orders/add_order_screen.dart';
import 'ui/revenues/manager_revenues_screen.dart';
import 'ui/screens.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
        ],
        child: Consumer<AuthManager>(
          builder: (ctx, authManager, child) {
            return MaterialApp(
              title: 'Katec',
              theme: ThemeData(
                fontFamily: 'Lato',
                colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.blue,
                ).copyWith(
                  secondary: Colors.deepOrange,
                ),
              ),
              home: authManager.isAuth
                  ? const ProductsOverviewScreen()
                  : FutureBuilder(
                      future: authManager.tryAutoLogin(),
                      builder: (ctx, snapshot) {
                        return snapshot.connectionState ==
                                ConnectionState.waiting
                            ? const SplashScreen()
                            : const AuthScreen();
                      },
                    ),
              // home: const ProductsOverviewScreen(),
              routes: {
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

                return null;
              },
            );
          },
        ));
  }
}
