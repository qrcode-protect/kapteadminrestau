import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/login/login_page.dart';
import 'package:libertyrestaurant/models/utilisateur/utilisateur.dart';
import 'package:libertyrestaurant/pages/etablissement/ajouter_etablissement.dart';
import 'package:libertyrestaurant/pages/pages.dart';
import 'package:libertyrestaurant/routing/route_state.dart';
import 'package:libertyrestaurant/state_management/state_management.dart';
import 'package:libertyrestaurant/widgets/fade_transition.dart';
import 'package:libertyrestaurant/widgets/my_drawer.dart';

const drawerOpenWidth = 240.0;
const drawerCloseWidth = 60.0;

final arrowValueProvider = StateNotifierProvider<ArrowValueState, bool>((ref) {
  return ArrowValueState();
});

class ArrowValueState extends StateNotifier<bool> {
  ArrowValueState() : super(false);
  void setValue(bool value) {
    state = value;
  }
}

class AppNavigatoreState extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const AppNavigatoreState({Key? key, required this.navigatorKey})
      : super(key: key);

  @override
  State<AppNavigatoreState> createState() => _AppNavigatoreStateState();
}

class _AppNavigatoreStateState extends State<AppNavigatoreState> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        return route.didPop(result);
      },
      pages: const [
        FadeTransitionPage<void>(
          child: FirstScreen(),
        ),
      ],
    );
  }
}

class FirstScreen extends ConsumerStatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const FirstScreen({Key? key}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends ConsumerState<FirstScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    return appState.user == null && !appState.awaitUser
        ? const LoginPage()
        : const MainScreen();
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  double drawerWidth = drawerOpenWidth;
  bool drawerOpen = true;
  Utilisateur? utilisateur;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context).route;
    final appState = ref.watch(appStateProvider);
    return appState.utilisateur != null
        ? Scaffold(
            appBar: AppBar(
              elevation: 2.0,
              leading: appState.utilisateur!.idRestaurant != null
                  ? IconButton(
                      onPressed: () => openAndCloseDrawer(),
                      icon: const Icon(Icons.menu),
                      splashRadius: 30,
                    )
                  : null,
              title: Text(
                'Restaurant Manager',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              centerTitle: false,
              actions: const [
                ProfilePopupMenu(),
              ],
            ),
            body: appState.utilisateur!.idRestaurant != null
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width < 800
                          ? 800
                          : MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                            height: double.infinity,
                            width: drawerWidth,
                            child: MyDrawer(
                              drawerOpen: drawerOpen,
                              drawerWidth: drawerWidth,
                            ),
                          ),
                          Expanded(
                            child: Navigator(
                              key: FirstScreen.navigatorKey,
                              onPopPage: (route, dynamic result) =>
                                  route.didPop(result),
                              pages: [
                                if (currentRoute.pathTemplate
                                    .startsWith('/accueil'))
                                  const FadeTransitionPage<void>(
                                    child: HomePage(),
                                  )
                                else if (currentRoute.pathTemplate
                                    .startsWith('/settings'))
                                  const FadeTransitionPage<void>(
                                    child: SettingPage(),
                                  )
                                else if (currentRoute.pathTemplate
                                    .startsWith('/commandes'))
                                  const FadeTransitionPage<void>(
                                    child: CommmandesPage(),
                                  )
                                else if (currentRoute.pathTemplate
                                    .startsWith('/paiements'))
                                  const FadeTransitionPage<void>(
                                    child: PaiementsPage(),
                                  )
                                else if (currentRoute.pathTemplate
                                    .startsWith('/menus'))
                                  const FadeTransitionPage<void>(
                                    child: MenusPage(),
                                  )
                                else if (currentRoute.pathTemplate
                                    .startsWith('/etablissement'))
                                  const FadeTransitionPage<void>(
                                    child: EtablissementPage(),
                                  )
                                else if (currentRoute.pathTemplate
                                    .startsWith('/compte'))
                                  const FadeTransitionPage<void>(
                                    child: ComptesPage(),
                                  )
                                else if (currentRoute.pathTemplate
                                    .startsWith('/documents'))
                                  const FadeTransitionPage<void>(
                                    child: DocumentsPage(),
                                  )
                                else
                                  FadeTransitionPage<void>(
                                    key: const ValueKey('empty'),
                                    child: Container(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(child: AjouterEtablissement()),
          )
        : const Scaffold(
            body: LinearProgressIndicator(
              minHeight: 8,
            ),
          );
  }

  openAndCloseDrawer() {
    setState(() {
      drawerOpen = !drawerOpen;
      drawerOpen
          ? drawerWidth = drawerOpenWidth
          : drawerWidth = drawerCloseWidth;
    });
  }
}

class ProfilePopupMenu extends StatefulWidget {
  const ProfilePopupMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePopupMenu> createState() => _ProfilePopupMenuState();
}

class _ProfilePopupMenuState extends State<ProfilePopupMenu> {
  bool arrowValue = false;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final appState = ref.watch(appStateProvider);

      return PopupMenuButton(
        offset: const Offset(0, 60),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              appState.utilisateur!.avatar.isNotEmpty
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          NetworkImage(appState.utilisateur!.avatar),
                    )
                  : const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
              Consumer(builder: (context, ref, _) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: !arrowValue
                      ? const Icon(Icons.arrow_drop_down)
                      : const Icon(Icons.arrow_drop_up),
                );
              })
            ],
          ),
        ),
        itemBuilder: (context) {
          setState(() {
            arrowValue = !arrowValue;
          });
          return const [
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.exit_to_app_outlined),
                title: Text("Deconnexion"),
              ),
              value: 1,
            ),
          ];
        },
        onSelected: (int index) {
          if (index == 1) {
            ref.read(appStateProvider).signOut();
          }
        },
        tooltip: appState.user!.email,
        onCanceled: () {
          setState(() {
            arrowValue = !arrowValue;
          });
        },
      );
    });
  }
}
